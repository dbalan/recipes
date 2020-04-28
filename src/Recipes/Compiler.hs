{-# LANGUAGE OverloadedStrings #-}
module Recipes.Compiler
  ( startApp
  )
where

import Hakyll
import Hakyll.Core.Identifier (toFilePath)
import System.FilePath

import Recipes.RecipeCompiler

config :: Configuration
config = defaultConfiguration
  { destinationDirectory = "public" }

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
  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- loadAll "recipes/*"
      let indexCtx =
            listField "posts" defaultContext (return posts) <> defaultContext
      makeItem ""
        >>= loadAndApplyTemplate "templates/index.html" indexCtx
        >>= relativizeUrls
