#!/usr/bin/env bash

wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/0.265.1/presto-cli-0.265.1-executable.jar
mv presto-cli-0.265.1-executable.jar presto
chmod +x presto
