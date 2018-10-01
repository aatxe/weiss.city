{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll

main :: IO ()
main = hakyll $ do
  match ("cv.pdf" .||. "images/*" .||. "pubs/*.pdf" .||. "gradapps/*.pdf" .||. "*.png" .||. "*.ico") $ do
    route idRoute
    compile copyFileCompiler

  match "css/*" $ compile getResourceBody

  create ["master.css"] $ do
    route idRoute
    compile $ do
      css <- loadAll "css/*"
      makeItem $ concatMap (compressCss . itemBody) (css :: [Item String])

  match "index.md" $ do
    route $ setExtension "html"
    compile $ do
      pubs <- recentFirst =<< loadAll "pubs/*.md"
      let pubsCtx =
            listField "pubs" pubCtx (return pubs) `mappend`
            defaultContext

      pandocCompiler
        >>= loadAndApplyTemplate "templates/default.html" pubsCtx
        >>= relativizeUrls

  match "oneoffs/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/oneoff.html" defaultContext
      >>= relativizeUrls

  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= saveSnapshot "content"
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  -- This route is needed to build pubs.
  match "pubs/*.md" $ compile pandocCompiler

  create ["rss.xml"] $ do
    route idRoute
    compile $ do
      loadAllSnapshots "posts/*" "content"
        >>= fmap (take 10) . recentFirst
        >>= renderRss (feedConfiguration "Recent Posts") feedCtx

  create ["archive.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts) `mappend`
            constField "title" "Archives"            `mappend`
            defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  match "templates/*" $ compile templateCompiler

--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
  dateField "date" "%B %e, %Y" `mappend`
  constField "post" "true"     `mappend`
  defaultContext

pubCtx :: Context String
pubCtx =
  dateField "date" "%B %Y" `mappend`
  defaultContext

feedCtx :: Context String
feedCtx =
  bodyField "description" `mappend`
  defaultContext

feedConfiguration :: String -> FeedConfiguration
feedConfiguration title = FeedConfiguration {
      feedTitle       = "Aaron Weiss / " ++ title
    , feedDescription = "Personal blog of Aaron Weiss"
    , feedAuthorName  = "Aaron Weiss"
    , feedAuthorEmail = "awe@pdgn.co"
    , feedRoot        = "https://aaronweiss.us"
}
