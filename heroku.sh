#!/bin/bash
heroku create --buildpack https://github.com/ddollar/heroku-buildpack-multi.git $1
