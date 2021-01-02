{-# LANGUAGE OverloadedStrings #-}
module Recipes.Compiler
  ( startApp
  )
where

import Hakyll
import System.FilePath

import Recipes.RecipeCompiler

config :: Configuration
config = defaultConfiguration
  { destinationDirectory = "public"
   , deployCommand = "rsync -vrP public/ www:/usr/local/www/nginx/recipes/"
  }

recipeRoute :: Routes
recipeRoute = customRoute rr
  where
    rr :: Identifier -> FilePath
    rr p = (toFilePath p) -<.> ".html"

startApp :: IO ()
startApp = hakyllWith config $ do
  match "pictures/*" $ do
    route idRoute
    compile copyFileCompiler

  match "recipes/*.yaml" $ do
    route recipeRoute
    compile recipeCompiler

  match "templates/*" $ compile templateBodyCompiler
  match "css/*" $ do
    route idRoute
    compile copyFileCompiler

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- loadAll "recipes/*"
      let indexCtx =
            listField "posts" defaultContext (return posts) <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/index.html" indexCtx
        >>= relativizeUrls
