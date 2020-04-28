{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE RecordWildCards   #-}

module Recipes.Types where

import Data.String.Interpolate
import Data.Yaml

data Recipe = Recipe
  { title :: String
  , description :: String
  , source :: String
  , ingredients :: ![RecipeIngredient]
  , categories :: ![String]
  , instructions :: ![Instruction]
  , notes :: Maybe String } deriving (Show, Eq)

data RecipeIngredient = RecipeIngredient
  { name :: String
  , prep :: Maybe String
  , qty :: Maybe String } deriving (Show, Eq)

data Instruction = Instruction
  { instructionName :: String
  , steps :: !String } deriving (Show, Eq)

instance FromJSON Instruction where
  parseJSON = withObject "instruction" $ \o -> do
    instructionName <- o .: "name"
    steps <- o .: "prep"
    pure Instruction{..}

instance FromJSON RecipeIngredient where
  parseJSON = withObject "ingredient" $ \o -> do
    name <- o .: "name"
    prep <- o .:? "prep"
    qty <- o .:? "qty"
    pure RecipeIngredient{..}

instance FromJSON Recipe where
  parseJSON = withObject "recipe" $ \o -> do
    title <- o .: "title"
    description <- o .: "description"
    source <- o .: "source"
    ingredients <- o .: "ingredients"
    categories <- o .: "categories"
    instructions <- o .: "preparation"
    notes <- o .:? "notes"
    pure Recipe{..}

-- | alternative to show, since I need show for debugging
class Render a where
  render :: a -> String

instance Render RecipeIngredient where
  render ins = name ins <> prep'
    where
      prep' = case prep ins of
                Nothing -> ""
                Just p  -> " (" <> p <> ")"

instance Render Instruction where
  render ins =
    [i|<h3>#{instructionName ins}</h3>
       #{steps ins}\n|]
