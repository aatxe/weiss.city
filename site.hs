--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  match ("cv.pdf" .||. "images/*" .||. "pubs/*.pdf" .||. "*.png" .||. "*.ico") $ do
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
    let homeCtx =
          constField "home" "true"  `mappend`
          constField "image" "true" `mappend`
          defaultContext

    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/home.html" homeCtx
      >>= relativizeUrls

  match "oneoffs/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/oneoff.html" defaultContext
      >>= relativizeUrls

  match "posts/*" $ do
    route $ setExtension "html"
    compile $ pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  -- This no route is needed to build pubs.
  match "pubs/*.md" $ compile pandocCompiler

  create ["archive.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts) `mappend`
            constField "title" "Archives"            `mappend`
            constField "home" "true"                 `mappend`
            defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  create ["pubs.html"] $ do
    route idRoute
    compile $ do
      pubs <- recentFirst =<< loadAll "pubs/*.md"
      let pubsCtx =
            listField "pubs" pubCtx (return pubs) `mappend`
            constField "title" "Publications"     `mappend`
            constField "home" "true"              `mappend`
            defaultContext

      makeItem ""
        >>= loadAndApplyTemplate "templates/pubs.html" pubsCtx
        >>= loadAndApplyTemplate "templates/default.html" pubsCtx
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
