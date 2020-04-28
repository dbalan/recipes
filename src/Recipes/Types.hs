{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE RecordWildCards   #-}

module Recipes.Types where

import Data.Text

import Data.Yaml

data Recipe = Recipe
  { title :: Text
  , description :: Text
  , source :: Text
  , yields :: Maybe Integer
  , ingredients :: ![RecipeIngredient]
  , categories :: ![Text]
  , instructions :: ![Instruction]
  , notes :: [Text] } deriving (Show, Eq)

data RecipeIngredient = RecipeIngredient
  { name :: Text
  , prep :: Maybe Text
  , qty :: Maybe Text } deriving (Show, Eq)

data Instruction = Instruction
  { instructionName :: Text
  , steps :: ![Text] } deriving (Show, Eq)

instance FromJSON Instruction where
  parseJSON = withObject "instruction" $ \o -> do
    instructionName <- o .: "name"
    steps <- o .: "steps"
    pure Instruction{..}

instance FromJSON RecipeIngredient where
  parseJSON = withObject "ingredient" $ \o -> do
    name <- o .: "name"
    prep <- o .:? "prep"
    qty <- o .:? "qty"
    pure RecipeIngredient{..}


