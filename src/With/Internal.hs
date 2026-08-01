{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Internal API for "With".
module With.Internal
  ( Bind (..),
    Then (..),
    With (..),
    with,
    CurryN (..),
  )
where

infixl 1 >>=

infixl 1 >>

--------------------------------------------------------------------------------

class Bind a b c where
  -- | Generalized monadic bind used by QualifiedDo. See "With".
  --
  -- Example types:
  --
  -- @
  -- -- ordinary monadic bind
  -- (>>=) :: 'Monad' m => m a -> (a -> m b) -> m b
  -- -- with, one-argument trailing lambda
  -- (>>=) :: t'With' ((a -> b) -> r) -> (a -> b) -> r
  -- -- with, two-argument trailing lambda
  -- (>>=) :: t'With' ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
  -- ...
  -- @
  (>>=) :: a -> b -> c

class Then a b c where
  -- | Generalized monadic sequencing used by QualifiedDo. See "With".
  --
  -- Example types:
  --
  -- @
  -- -- ordinary monadic sequencing
  -- (>>) :: 'Monad' m => m a -> m b -> m b
  -- -- with, without binding
  -- (>>) :: t'With' (a -> r) -> a -> r
  -- @
  (>>) :: a -> b -> c

-- Fall back to the standard monad operations

instance {-# OVERLAPPABLE #-} (Monad m, a ~ m a', b ~ (a' -> m b'), c ~ m b') => Bind a b c where
  (>>=) = (Prelude.>>=)
  {-# INLINE (>>=) #-}

instance {-# OVERLAPPABLE #-} (Monad m, a ~ m a', b ~ m b', c ~ m b') => Then a b c where
  (>>) = (Prelude.>>)
  {-# INLINE (>>) #-}

--------------------------------------------------------------------------------

-- | Marks a function for @with@ semantics.
newtype With a = With a

-- | Use a function as a @with@ statement.
with :: a -> With a
with = With
{-# INLINE with #-}

instance (CurryN fn' fn, r ~ r') => Bind (With (fn -> r)) fn' r' where
  With f >>= g = f (curryN g)
  {-# INLINE (>>=) #-}

instance (a ~ a', r ~ r') => Then (With (a -> r)) a' r' where
  With f >> x = f x
  {-# INLINE (>>) #-}

class CurryN fn fn' | fn -> fn' where
  curryN :: fn -> fn'

-- Main instance
instance CurryN (a -> b) (a -> b) where
  curryN = id
  {-# INLINE curryN #-}

-- Support for trailing lambdas with multiple parameters

instance CurryN ((# #) -> a) a where
  curryN f = f (# #)
  {-# INLINE curryN #-}

instance CurryN ((# a #) -> b) (a -> b) where
  curryN f a = f (# a #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b #) -> c) (a -> b -> c) where
  curryN f a b = f (# a, b #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b, c #) -> d) (a -> b -> c -> d) where
  curryN f a b c = f (# a, b, c #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b, c, d #) -> e) (a -> b -> c -> d -> e) where
  curryN f a b c d = f (# a, b, c, d #)
  {-# INLINE curryN #-}

instance CurryN ((# a, b, c, d, e #) -> f) (a -> b -> c -> d -> e -> f) where
  curryN f a b c d e = f (# a, b, c, d, e #)
  {-# INLINE curryN #-}
