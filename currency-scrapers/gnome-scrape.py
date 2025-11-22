from bs4 import BeautifulSoup
import requests
import sys
import re
from natsort import natsorted
from packaging.version import parse as parseVersion
import copy
#url=sys.argv[1]
#url="https://mirrors.edge.kernel.org/pub/linux/kernel/v6.x/"



def get_versions(url):
  versions=[]
  page = requests.get(url).text
  doc = BeautifulSoup(page, "html.parser")
  links = doc.find_all('a')
  for link in links: 
    version = re.search(r'[0-9]+.[0-9]+', link.string)
    if version:
       versions.append(copy.deepcopy(version.group()))
  versions.sort(key = parseVersion)
  return versions

def checkIfRelease(links):
  for i in links:
    if ("LATEST" in i.string) and (("alpha" in i.string) or ("beta" in i.string) or ("rc" in i.string)):
      return False
  return True



url=sys.argv[1]
url2 = url + '/' + get_versions(url)[-1]
print(url2)

page = requests.get(url2).text
doc = BeautifulSoup(page, "html.parser")
links = doc.find_all('a')
if not checkIfRelease(links):
    url2 = url + '/' + get_versions(url)[-2]
    page = requests.get(url2).text
    doc = BeautifulSoup(page, "html.parser")
    links = doc.find_all('a')

for link in links:
  print(link.string)


