{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UnboxedTuples #-}
{-# LANGUAGE UndecidableInstances #-}

-- | Internal API for "With".
module With.Internal
  ( Bind (..),
    (With.Internal.>>),
  )
where

infixl 1 >>=

--------------------------------------------------------------------------------

-- | Standard monadic sequencing used by QualifiedDo. See "With".
(>>) :: (Monad m) => m a -> m b -> m b
(>>) = (Prelude.>>)
{-# INLINE (>>) #-}

class Bind a b c where
  -- | Generalized monadic bind used by QualifiedDo. See "With".
  --
  -- Instance types include:
  --
  -- @
  -- -- ordinary monadic bind
  -- (>>=) :: 'Monad' m => m a -> (a -> m b) -> m b
  -- -- with, without binding
  -- (>>=) :: (a -> r) -> ((# #) -> a) -> r
  -- -- with, one-argument trailing lambda
  -- (>>=) :: ((a -> b) -> r) -> ((# a #) -> b) -> r
  -- -- with, two-argument trailing lambda
  -- (>>=) :: ((a -> b -> c) -> r) -> ((# a, b #) -> c) -> r
  -- ...
  -- @
  (>>=) :: a -> b -> c

-- Fall back to the standard monad operations

instance {-# OVERLAPPABLE #-} (Monad m, a ~ m a', b ~ (a' -> m b'), c ~ m b') => Bind a b c where
  (>>=) = (Prelude.>>=)
  {-# INLINE (>>=) #-}

--------------------------------------------------------------------------------
-- With statements

instance (a ~ a', r ~ r') => Bind (a -> r) ((# #) -> a') r' where
  f >>= g = f (g (# #))
  {-# INLINE (>>=) #-}

instance (a ~ a', b ~ b', r ~ r') => Bind ((a -> b) -> r) ((# a' #) -> b') r' where
  f >>= g = f (\a -> g (# a #))
  {-# INLINE (>>=) #-}

instance (a ~ a', b ~ b', c ~ c', r ~ r') => Bind ((a -> b -> c) -> r) ((# a', b' #) -> c') r' where
  f >>= g = f (\a b -> g (# a, b #))
  {-# INLINE (>>=) #-}

instance (a ~ a', b ~ b', c ~ c', d ~ d', r ~ r') => Bind ((a -> b -> c -> d) -> r) ((# a', b', c' #) -> d') r' where
  f >>= g = f (\a b c -> g (# a, b, c #))
  {-# INLINE (>>=) #-}

instance (a ~ a', b ~ b', c ~ c', d ~ d', e ~ e', r ~ r') => Bind ((a -> b -> c -> d -> e) -> r) ((# a', b', c', d' #) -> e') r' where
  f >>= g = f (\a b c d -> g (# a, b, c, d #))
  {-# INLINE (>>=) #-}

instance (a ~ a', b ~ b', c ~ c', d ~ d', e ~ e', f ~ f', r ~ r') => Bind ((a -> b -> c -> d -> e -> f) -> r) ((# a', b', c', d', e' #) -> f') r' where
  f >>= g = f (\a b c d e -> g (# a, b, c, d, e #))
  {-# INLINE (>>=) #-}

instance (a ~ a', b ~ b', c ~ c', d ~ d', e ~ e', f ~ f', g ~ g', r ~ r') => Bind ((a -> b -> c -> d -> e -> f -> g) -> r) ((# a', b', c', d', e', f' #) -> g') r' where
  f >>= g = f (\a b c d e f -> g (# a, b, c, d, e, f #))
  {-# INLINE (>>=) #-}
