# GitHub Page

This repo feeds into the associated GitHub page [jameselliothart.github.io](https://jameselliothart.github.io).
The `content` branch contains source files while the GitHub page is served out of `master` and is generated
through pelican and ghp-import.

The articles below were instrumental in this implementation:

* [Run your blog on GitHub Pages with Python](https://opensource.com/article/19/5/run-your-blog-github-pages-python)
* [How to Create Your First Static Site with Pelican and Jinja2](https://www.fullstackpython.com/blog/generating-static-websites-pelican-jinja2-markdown.html)

## Development Notes

### Local Dev

Run locally on `http://localhost:8000/` with:  
`$ make devserver`

### Publishing

Run Pelican to generate the static HTML files in output:  
`$ pelican content -o output -s publishconf.py`

Use ghp-import to add the contents of the output directory to the master branch:  
`$ ghp-import -m "Generate Pelican site" --no-jekyll -b master output`

Push the local master branch to the remote repo:  
`$ git push origin master`

Finally, commit and push the new content to the content branch.
