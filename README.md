# Tucana-Autobuild

The autobuild system used for Tucana. This likely should not be run by an end user.

# What?
Oversimplifying, this repo contains a variety of scripts that scrape the internet to 1) Find the latest version of a program 2) Update it.

It does this by web-scraping and then creating a fresh image of Tucana that it chroot's into for the build

# Why?
Tucana is incredibly difficult to maintain as it is. This takes the majority of the load off and allows me to get back to making more features and adding to the unique parts of the distro instead of spending all my time mindlessly updating packages. (See git commits from before Jun of 2023 to see what that was like)

# Usage
This was NOT designed for the end-user, this is considered an internal tool but here are instructions to use it.
(currency is the process of checking if a program is out-of-date). We would like to emphasize that this program has NO WARRANTY, We are not responsible
for any harm to your system. That being said, if you follow the directions below there is a 99% chance no harm will be done, Autobuild uses a chroot which attempts to isolate
itself from your host system.
**If you are planning to modify this in any way please read the next "Repo Structure" section before reading this one** 
## Setup
You MUST be on Tucana to run this and have at least 30gb of free space
### Install dependencies
```sudo neptune install python-requests python-urllib3 python-packaging```  
### Install BeautifulSoup from neptune
```sudo neptune install python-beautifulsoup4```
### Clone the Repo
```git clone https://github.com/Tucana-Linux/Tucana-Autobuild.git && cd Tucana-Autobuild```
Make sure you have a global email and name set for Git (google it), Tucana-Autobuild uses git internally for revision tracking

### Create a Github personal access token
https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens
Get the key (ghp.*) and put it in a file in /srv/secret.txt, this is where autobuild expects it to be. You can change the location in autobuild.conf

### Run prep.sh
```sudo ./prep.sh```

### Change Repository(s) (if applicable)
If you want to use your own Tucana binary or build-scripts repository and not https://repo.tucanalinux.org/development/mercury and https://github.com/Tucana-Linux/Tucana-Build-Scripts.git change REPO=$ in autobuild.conf

### Change Tucana server specific settings
The autobuild.sh file has Tucana build-server specific settings embedded. The only one you have to care about is email_from_tucana.sh in the email_upgrades function and notify_failed_package function. You can comment them out or change them for your own script that can email a file. No harm comes from commenting out, you can still see the upgrade log in currency/email_upgrades.txt and failed updates in currency/failed_*.txt

### Run autobuild
```sudo ./autobuild.sh ```

### Retrieve the packages
The packages that successfully built can be found in chroot/finished/, all build logs are saved in logs/ and anything that failed is denoted by currency/failed_*.txt so you can fix them (keep in mind a package can fail because of a currency check error as well). Put the finished packages into your repo server and run ./rebuild-repo.sh (recommend commenting out the last line which is server specific to upload the new packages to the offical Tucana repo)
## Custom Flags
Certain bash comments in the build scripts have an effect on how the autobuild is run,  

```#HOLD_TUCANA``` -- Makes autobuild skip this package, it will not scrape the website for this package  
```#ARCH_VAR #ARCH_PKG``` -- Cheat code to currency, this will retrieve the package version from the Arch Linux repositories if 7 is specified in the scraper-key, this should be a last ditch method. ARCH_VAR is the variable in the PKGBUILD for the package version (typically pkgver) ARCH_PKG is the package name in the arch repository.  
```#TAG_OVERRIDE``` -- If using Github (3), it will force it to use tags instead of releases to find the latest version.


## Adding Packages
To add a package 
1) Add it to the Tucana-Build-Scripts repo (or a fork). Make sure it has a PKG_VER before the URL. Many Tucana Packages use a $MAJOR flag that can be found in packages like gedit, feel free to reuse it.
2)  Look at the URL and check the source. If the source is not one of the specific ones in the list below it is probably Standard or recursive standard. Find the number in the list below, see note above about 7.
```
  1) Standard (classic-parse.sh)
  2) Recursive Standard (Including Major) (recursive-parse.sh)
  3) Github (github-api-scrape.sh)
  4) Gnome
  5) Gnome (DE) (GNOME_DE=1 gnome-scrape.sh) 
  6) Sourceforge (Doesn't work reliably try to use another method)
  7) Arch
  8) Gitlab
```
3) Add it to scrapers-key/$DIRECTORY-currency.txt (see note below about adding directories and which file to add it to, if it's in the root of the repo it should be in root-currency.txt). Append a new line in the format ```name: num``` if you want to use a script that is not numbered (e.g pypi.sh for python-modules) put the full script name in for num (not path only the name)
4) Test, run autobuild.sh with the new package and exit (Ctrl+c) right as it starts spewing Git messages. Check currency/latest-ver.txt and check if currency successfully found the latest version, if it didn't, you are going to have to copy some base script in currency-scrapers/ and modify it until it works with seds greps and awks, or file an issue and we will help
5) If it didn't work you can run currency-scrapers/$SCRIPT.sh again without having to rerun every currency

Tip: gvfs.sh can be used for gnome packages that operate on the even-minor-is-stable pattern

# Repo Structure
```automation-scripts/``` -- Used for abstracting certain menial parts of checking package versions. The only thing you probably want to edit in here is ```generate_pkgvers.sh``` which generates the in-repo package versions; If you add a new directory to Tucana-Build-Scripts you will need to add it here by ammending it to find command on line 6. ```automate.sh``` is not used for the autobuild itself and is left in as a historical remenant.  

```currency-scrapers/``` -- This contains the web scraping code to find new versions. See the Usage/Adding packages section for information on the way these interact with the rest of autobuild. This has a couple python files that use BeautifulSoup4 and packaging to output all available files on a web-server (in the case of recursive all avaiable files of the latest major). If a currency-scraper listed in adding packages does not work, copy another one and make a new one ending in .sh here.

```full-tree-depend/``` -- This will likely be removed soon, this contains the all dependencies of every package in the repository as of Oct 2023. This is used for ordering during builds. It is likely this will be removed in favor of neptune's internal dependency resolver  

```scrapers-key/``` -- This contains lookup-tables for which currency-scraper script (from currency-scrapers) to use for scraping the version. Each folder in the main repository should get a .txt file here in the format $DIRECTORY-currency.txt. All files in this directory will automatically be used, just make sure to update ```automation-scripts/generate_pkgvers.sh```  

```prep.sh``` -- This will take the directory that you are currently in and update autobuild.conf so you don't have to modify it manually.  

```lib32-match.txt``` -- Any package that has a lib32 counterpart should be listed in here so currency does not have to be repeated  

```autobuild.conf``` -- The configuration file for autobuild. If you place your github api-key in /srv/secret.txt you likely won't need to modify this beyond running ./prep.sh  

# Other things
The script auto clones the build-scripts repo and uses git to commit new versions. It will automatically rollback packages that have failed.  
currency/ is the temporary storage for all the random files that autobuild generates.  

# Contributing
We always welcome contributors, feel free to file PRs or an issue.
