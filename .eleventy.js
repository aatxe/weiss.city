const syntaxHighlight = require("@11ty/eleventy-plugin-syntaxhighlight");
const pluginRss = require("@11ty/eleventy-plugin-rss");
const CleanCSS = require("clean-css");

module.exports = function(eleventyConfig) {
  eleventyConfig.ignores.add("README.md");

  eleventyConfig.addPassthroughCopy("images");
  eleventyConfig.addPassthroughCopy("gradapps");
  eleventyConfig.addPassthroughCopy("pubs/*.pdf");
  eleventyConfig.addPassthroughCopy("*.pdf");
  eleventyConfig.addPassthroughCopy("*.png");
  eleventyConfig.addPassthroughCopy("*.ico");

  eleventyConfig.addPlugin(syntaxHighlight);
  eleventyConfig.addPlugin(pluginRss);

  let markdownIt = require("markdown-it");
  let markdownItFootnote = require("markdown-it-footnote");
  let markdownItImageFigures = require("markdown-it-image-figures");
  let options = { html: true };
  let mdLib = markdownIt(options);

  mdLib.use(markdownItFootnote);

  mdLib.use(markdownItImageFigures, {
    dataType: true,
    figcaption: true,
  });

  eleventyConfig.setLibrary("md", mdLib);

  eleventyConfig.addFilter("cssmin", function(code) {
    return new CleanCSS({}).minify(code).styles;
  });

  eleventyConfig.addCollection("pubs", function(collectionApi) {
    return collectionApi.getAllSorted().filter(function(item) {
      // Side-step tags and do your own filtering
      return "pubdate" in item.data;
    });
  });

  eleventyConfig.addCollection("posts", function(collectionApi) {
    return collectionApi.getFilteredByGlob("posts/*.md");
  });
};
