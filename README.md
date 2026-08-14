# with

QualifiedDo notation for mixing monadic actions with [Koka-style with statements](https://koka-lang.github.io/koka/doc/book.html#sec-with).

```haskell
{-# LANGUAGE QualifiedDo #-}
{-# LANGUAGE UnboxedTuples #-}

import With
import Control.Exception
import Data.Foldable
import Text.Printf

forPair_ :: (Applicative m) => [(a, b)] -> (a -> b -> m ()) -> m ()
forPair_ xs f = for_ xs (uncurry f)

main = With.do
  -- ordinary monadic bind and sequencing
  s <- getLine
  print s
  -- with, without binding
  with (`finally` putStrLn "Bye!")
  -- with, binding one argument
  n <- with (for_ [0 :: Int .. 3])
  -- with, binding multiple arguments
  (# k, v #) <- with (forPair_ [("foo", 1), ("bar", 2)])
  printf "n = %d, k = %s, v = %d\n" n k v
```

With statements are first-class and can be named and reused.

```haskell
defer :: IO () -> With (IO a -> IO a)
defer cleanup = with (`finally` cleanup)

main = With.do
  defer (putStrLn "Bye!")
  putStrLn "Hello!"
```

## Limitation

A polymorphic monadic statement whose result could be a function may require additional type information:

```haskell
With.do
  n <- pure 42 :: IO Int
  m <- pure @IO 42 -- with -XTypeApplications
  ...
```

An alternative API that avoids this limitation is available on the [simplify](https://github.com/wasabi315/with/tree/simplify) branch. It marks with statements using unboxed tuples, whereas the main API uses a newtype `With`:

```haskell
With.do
  -- ordinary monadic bind and sequencing
  s <- getLine
  print s
  -- with, without binding
  (# #) <- (`finally` putStrLn "Bye!")
  -- with, binding one argument
  (# n #) <- for_ [0 :: Int .. 3]
  -- with, binding multiple arguments
  (# k, v #) <- forPair_ [("foo", 1), ("bar", 2)]
```

In this alternative, with statements cannot be named as helpers, but ordinary do notation is accepted more reliably and type errors are usually clearer.
The main API instead favors readability and first-class abstraction.
