{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE TemplateHaskell #-}

module Main where

import Test.Inspection
import With.Internal as With

-- bind0 :: (Monad m) => m a -> (a -> m b) -> m b
--   ^^ doesn't type check because of overlapping instances
bind0 :: (Monad m) => m Char -> (Char -> m b) -> m b
bind0 m f = With.do { x <- m; f x }

bind0' :: (Monad m) => m Char -> (Char -> m b) -> m b
bind0' m f = do { x <- m; f x }

bind1 :: With ((a -> b) -> r) -> (a -> b) -> r
bind1 f g = With.do { x <- f; g x }

bind1' :: With ((a -> b) -> r) -> (a -> b) -> r
bind1' (With f) g = f (\a -> g a)

bind2 :: With ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
bind2 f g = With.do { x <- f; g x }

bind2' :: With ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
bind2' (With f) g = f (\a b -> g (# a, b #))

-- then0 :: (Monad m) => m a -> m b -> m b
--   ^^ doesn't type check because of overlapping instances
then0 :: (Monad m) => m Char -> m b -> m b
then0 m n = m With.>> n

then0' :: (Monad m) => m Char -> m b -> m b
then0' m n = do { m; n }

then1 :: With (a -> r) -> a -> r
then1 f x = With.do { f; x }

then1' :: With (a -> r) -> a -> r
then1' (With f) x = f x

inspect $ 'bind0 ==- 'bind0'
inspect $ 'bind1 ==- 'bind1'
inspect $ 'bind2 ==- 'bind2'
inspect $ 'then0 ==- 'then0'
inspect $ 'then1 ==- 'then1'

main :: IO ()
main = pure ()
