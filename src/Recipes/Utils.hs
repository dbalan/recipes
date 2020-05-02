module Recipes.Utils where

import Data.Char (toUpper)

camelCase :: String -> String
camelCase (x:xs) = (toUpper x):xs
camelCase []     = []
