MESSAGE=$1

pelican content -o output -s publishconf.py 
ghp-import -m "$MESSAGE" --no-jekyll -b master output
git push origin master
