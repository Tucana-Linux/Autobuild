#!/bin/bash
curl -s https://api.github.com/repos/LuaJIT/LuaJIT/commits | jq '.[0].commit.author.date' | grep -Eo '[0-9]+-[0-9]+-[0-9]+' | sed 's/-//g'

