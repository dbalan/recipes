{-# LANGUAGE OverloadedStrings #-}
module Recipes.Compiler
  ( startApp
  )
where

import Hakyll

config :: Configuration
config = defaultConfiguration
  { destinationDirectory = "public" }

startApp :: IO ()
startApp = hakyllWith config $ do
  match "images/*" $ do
    route idRoute
    compile copyFileCompiler

