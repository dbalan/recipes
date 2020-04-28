{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes       #-}

module Recipes.RecipeCompiler where

import Data.ByteString.UTF8
import Data.Maybe
import Data.String.Interpolate
import Data.Yaml
import Hakyll.Core.Compiler
import Hakyll.Core.Identifier
import Hakyll.Core.Item
import Hakyll.Web.Template
import Hakyll.Web.Template.Context

import Recipes.Types

recipeCompiler :: Compiler (Item String)
recipeCompiler = do
  body <- getResourceBody
  case parseRecipe (itemBody body) of
    Left e  -> fail ("parse failed for:" <> show (toFilePath (itemIdentifier body)) <> " , " <> show e)
    Right b -> let c = fromRecipe b in
      makeItem "" >>=
      loadAndApplyTemplate "templates/recipe.html" c


parseRecipe :: String -> Either ParseException Recipe
parseRecipe s = decodeEither' (fromString s)

fromRecipe :: Recipe -> Context String
fromRecipe r = optionalField "notes" (notes r)
               <> optionalField "image" (image r)
               <> constField "title" (title r)
               <> constField "source" (source r)
               <> constField "desc" (description r)
               <> constField "notes" (noteli')
               <> constField "body" (renderBody r)

optionalField :: String -> Maybe String -> Context String
optionalField k v = case v of
  Nothing -> mempty
  Just s  -> constField k s

renderBody :: Recipe -> String
renderBody r =
  [i|<h2>Ingredients</h2>
    <table>
    #{renderIngredients r}
    </table>

    <h2>Instructions</h2>
    #{renderPrep r}
    |]

renderIngredients :: Recipe -> String
renderIngredients r = concat $ map renderIng (ingredients r)

renderPrep :: Recipe -> String
renderPrep r = concat $ map render (instructions r)

renderIng :: RecipeIngredient -> String
renderIng ing = [i|
        <tr>
            <td>#{fromMaybe "" (qty ing)}</td>
            <td>#{render ing}</td>
        </tr>
        |]
