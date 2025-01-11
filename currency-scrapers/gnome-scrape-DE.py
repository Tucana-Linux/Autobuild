from bs4 import BeautifulSoup
import requests
import sys
import re
from natsort import natsorted
from packaging.version import parse as parseVersion
import copy
url=sys.argv[1]
#url="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/"



def return_latest_ver(url):
  versions=[]
  page = requests.get(url).text
  doc = BeautifulSoup(page, "html.parser")
  links = doc.find_all('a')
  for link in links: 
    version = re.search(r'[0-9]+', link.string)
    if version:
       versions.append(copy.deepcopy(version.group()))
  versions.sort(key = parseVersion)
  print(versions)
  latest_ver=versions[-1]
  return latest_ver


def getLinks(ver):
  url2 = url + '/' + str(ver)
  print(url2)

  page = requests.get(url2).text
  doc = BeautifulSoup(page, "html.parser")
  return doc.find_all('a')

def checkIfRelease(links):
  for i in links:
    if ".0" in i.string:
      return True
  return False

ver = return_latest_ver(url)
links = getLinks(ver)
if not checkIfRelease(links):
  ver = int(ver)
  ver-=1
  links=getLinks(ver)
  
for link in links:
  print(link.string)


