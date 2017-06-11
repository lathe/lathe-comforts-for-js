-- macros2.hs

-- This file isn't meant to become a Haskell library (yet, anyway).
-- It's just a scratch area to help guide the design of macros.rkt.


{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE Rank2Types #-}

import Data.Map (Map)



-- We demonstrate a way to extrapolate monads so to operate on kind
-- (* -> *), kind ((* -> *) -> (* -> *)), and so on (but we stop
-- there to avoid exhausting ourselves with clutter). We start with
-- regular monads which operate on kind *, and we call those
-- `H0Monad`.

class H0Monad m0 where
  -- minimal definition:
  --   h0return and (h0bind0 or (h0join0 and h0map0))
  h0map0 :: (a -> a') -> m0 a -> m0 a'
  h0map0 f = h0bind0 (h0return . f)
  h0return :: a -> m0 a
  h0join0 :: m0 (m0 a) -> m0 a
  h0join0 = h0bind0 id
  h0bind0 :: (a -> m0 a') -> m0 a -> m0 a'
  h0bind0 f = h0join0 . h0map0 f
class H1Monad m1 where
  -- minimal definition:
  --   h1return
  --     and (h1bind0 or (h1join0 and h1map0))
  --     and (h1bind1 or (h1join1 and h1map1))
  h1map0 :: (H0Monad m0) => (a -> a') -> m1 m0 a -> m1 m0 a'
  h1map0 f = h1bind0 (h0return . f)
  h1map1 ::
    (H0Monad m0, H0Monad m0') =>
    (forall a. m0 a -> m0' a) -> m1 m0 a -> m1 m0' a
  h1map1 f = h1bind1 (h1return . f)
  h1return :: (H0Monad m0) => m0 a -> m1 m0 a
  h1join0 :: (H0Monad m0) => m1 m0 (m1 m0 a) -> m1 m0 a
  h1join0 = h1bind0 id
  h1join1 :: (H0Monad m0) => m1 (m1 m0) a -> m1 m0 a
  h1join1 = h1bind1 id
  h1bind0 :: (H0Monad m0) => (a -> m1 m0 a') -> m1 m0 a -> m1 m0 a'
  h1bind0 f = h1join0 . h1map0 f
  h1bind1 ::
    (H0Monad m0, H0Monad m0') =>
    (forall a. m0 a -> m1 m0' a) -> m1 m0 a -> m1 m0' a
  h1bind1 f = h1join1 . h1map1 f
instance {-# OVERLAPPABLE #-}
  (H1Monad m1, H0Monad m0) => H0Monad (m1 m0)
  where
  h0map0 = h1map0
  h0return = h1return . h0return
  h0join0 = h1join0
  h0bind0 = h1bind0
class H2Monad m2 where
  -- minimal definition:
  --   h1return
  --     and (h2bind0 or (h2join0 and h2map0))
  --     and (h2bind1 or (h2join1 and h2map2))
  --     and (h2bind2 or (h2join2 and h2map2))
  h2map0 ::
    (H1Monad m1, H0Monad m0) => (a -> a') -> m2 m1 m0 a -> m2 m1 m0 a'
  h2map0 f = h2bind0 (h0return . f)
  h2map1 ::
    (H1Monad m1, H0Monad m0, H0Monad m0') =>
    (forall a. m0 a -> m0' a) -> m2 m1 m0 a -> m2 m1 m0' a
  h2map1 f = h2bind1 (h1return . f)
  h2map2 ::
    (H1Monad m1, H1Monad m1') =>
    (forall m0 a. (H0Monad m0) => m1 m0 a -> m1' m0 a) ->
    (forall m0 a. (H0Monad m0) => m2 m1 m0 a -> m2 m1' m0 a)
  h2map2 f = h2bind2 (h2return . f)
  h2return :: (H1Monad m1, H0Monad m0) => m1 m0 a -> m2 m1 m0 a
  h2join0 ::
    (H1Monad m1, H0Monad m0) => m2 m1 m0 (m2 m1 m0 a) -> m2 m1 m0 a
  h2join0 = h2bind0 id
  h2join1 ::
    (H1Monad m1, H0Monad m0) => m2 m1 (m2 m1 m0) a -> m2 m1 m0 a
  h2join1 = h2bind1 id
  h2join2 ::
    (H1Monad m1, H0Monad m0) => m2 (m2 m1) m0 a -> m2 m1 m0 a
  h2join2 = h2bind2 id
  h2bind0 ::
    (H1Monad m1, H0Monad m0) =>
    (a -> m2 m1 m0 a') -> m2 m1 m0 a -> m2 m1 m0 a'
  h2bind0 f = h2join0 . h2map0 f
  h2bind1 ::
    (H1Monad m1, H0Monad m0, H0Monad m0') =>
    (forall a. m0 a -> m2 m1 m0' a) -> m2 m1 m0 a -> m2 m1 m0' a
  h2bind1 f = h2join1 . h2map1 f
  h2bind2 ::
    (H1Monad m1, H1Monad m1') =>
    (forall m0 a. (H0Monad m0) => m1 m0 a -> m2 m1' m0 a) ->
    (forall m0 a. (H0Monad m0) => m2 m1 m0 a -> m2 m1' m0 a)
  h2bind2 f = h2join2 . h2map2 f
instance {-# OVERLAPPABLE #-}
  (H2Monad m2, H1Monad m1) => H1Monad (m2 m1)
  where
  h1map0 = h2map0
  h1map1 = h2map1
  h1return = h2return . h1return
  h1join0 = h2join0
  h1join1 = h2join1
  h1bind0 = h2bind0
  h1bind1 = h2bind1


-- We define some types which can correspond with unresolved identity
-- and composition operations in the "monoid in the category of
-- endofunctors" for higher and higher notions of "endofunctor." For
-- (H1Monad m0) and the type `a`, the monoid identity is (H0Id a), the
-- monoid composition is (H0Meta m0 a), and the notion of
-- "endofunctor" is a natural transformation between (actual)
-- endofunctors of the same category.
--
-- The reason we design these operations to keep the compositions
-- "unresolved" is so that we can pretend there's something in between
-- the two sides of the composition, such as how the closing bracket
-- in the text "[left]right" comes in between the composition of
-- "left" and "right".
--
-- TODO: Prove that these satisfy satisfactory laws to say they're
-- really monoid identity and composition and to be sure we're not
-- making incorrect category theory claims.

data H0Id a = H0Id { h0runId :: a }
instance H0Monad H0Id where
  h0return = H0Id
  h0bind0 f (H0Id a) = f a

data H1Id m0 a = H1Id { h1runId :: m0 a }
instance H1Monad H1Id where
  h1return = H1Id
  h1map0 f (H1Id m) = H1Id $ h0map0 f m
  h1join0 (H1Id m) = H1Id $ h0bind0 h1runId m
  h1bind1 f (H1Id m) = f m

data H2Id (m1 :: (* -> *) -> * -> *) m0 a =
  H2Id { h2runId :: m1 m0 a }
instance H2Monad H2Id where
  h2return = H2Id
  h2map0 f (H2Id m) = H2Id $ h1map0 f m
  h2join0 (H2Id m) = H2Id $ h1bind0 h2runId m
  h2map1 f (H2Id m) = H2Id $ h1map1 f m
  h2join1 (H2Id m) = H2Id $ h1bind1 h2runId m
  h2bind2 f (H2Id m) = f m

data H0Meta m0 a = H0Meta { h0runMeta :: m0 (m0 a) }
instance H1Monad H0Meta where
  h1return = H0Meta . h0return
  h1map0 f (H0Meta m) = H0Meta $ h0map0 (h0map0 f) m
  h1join0 (H0Meta m) = H0Meta $ h0bind0 (h0bind0 h0runMeta) m
  h1bind1 f (H0Meta m) = h0join0 $ f $ h0map0 f m

data H1Meta m1 m0 a = H1Meta { h1runMeta :: m1 (m1 m0) a }
instance H2Monad H1Meta where
  h2return = H1Meta . h1return
  h2map0 f (H1Meta m) = H1Meta $ h1map0 f m
  h2join0 (H1Meta m) = H1Meta $ h1bind0 h1runMeta m
  h2map1 f (H1Meta m) = H1Meta $ h1map1 (h1map1 f) m
  h2join1 (H1Meta m) = H1Meta $ h1bind1 (h1bind1 h1runMeta) m
  h2bind2 f (H1Meta m) = h1join1 $ f $ h1map1 f m


-- The (Balanced m0 a) type represents a document of balanced
-- parentheses, where the document's media (e.g. text) is encoded in
-- an `H0Monad` called `m0` and the document's end-of-file marker is a
-- value of type `a`. We show that `Balanced` itself is an
-- `H1Monad`... or at least we would show this if we properly
-- formulated the analogues to the monad laws for `H1Monad` (TODO).
--
-- TODO: See what it takes to generalize this to a higher degree of
-- quasiquotation. It won't be (Balanced (Balanced m0) a), because
-- that's just two variations of parentheses where the outer variation
-- can't occur anywhere inside the inner variation. We've started on a
-- possible generalization below (starting with `H0Balanced`), but we
-- haven't quite managed to implement an instance for
-- (H2Monad H1Balanced).

data Balanced m0 a
  = BalancedNonMedia (BalancedNonMedia m0 a)
  | BalancedMedia (m0 (BalancedNonMedia m0 a))
data BalancedNonMedia m0 a
  = BalancedEnd a
  | BalancedBrackets (Balanced m0 (Balanced m0 a))

instance H1Monad Balanced where
  h1return = BalancedMedia . h0map0 BalancedEnd
  h1bind0 f m = case m of
    BalancedNonMedia m' -> case m' of
      BalancedEnd a -> f a
      BalancedBrackets m'' ->
        BalancedNonMedia $ BalancedBrackets $ h0map0 (h1bind0 f) m''
    BalancedMedia m' -> BalancedMedia $ flip h0bind0 m' $ \m'' ->
      case h1bind0 f (BalancedNonMedia m'') of
        BalancedNonMedia m''' -> h0return m'''
        BalancedMedia m''' -> m'''
  
  -- NOTE: Defining `h1map1`, `h1join1`, and `h1bind1` here is
  -- redundant, but we do it anyway as an exercise.
  h1map1 f m = case m of
    BalancedNonMedia m' -> BalancedNonMedia $ h1map1nonMedia f m'
    BalancedMedia m' ->
      BalancedMedia $ h0map0 (h1map1nonMedia f) $ f m'
    where
    h1map1nonMedia ::
      (H0Monad m0, H0Monad m0') =>
      (forall a. m0 a -> m0' a) ->
      BalancedNonMedia m0 a ->
        BalancedNonMedia m0' a
    h1map1nonMedia f m = case m of
      BalancedEnd a -> BalancedEnd a
      BalancedBrackets m' ->
        BalancedBrackets $ h1map1 f $ h1map0 (h1map1 f) m'
  h1join1 m = case m of
    BalancedNonMedia m' -> BalancedNonMedia $ case m' of
      BalancedEnd a -> BalancedEnd a
      BalancedBrackets m'' ->
        BalancedBrackets $ h1join1 $ h1map0 h1join1 m''
    BalancedMedia m' ->
      h1join0 $ h1map0 (h1join1 . BalancedNonMedia) m'
  h1bind1 f m = case m of
    BalancedNonMedia m' -> BalancedNonMedia $ case m' of
      BalancedEnd a -> BalancedEnd a
      BalancedBrackets m'' ->
        BalancedBrackets $ h1bind1 f $ h1map0 (h1bind1 f) m''
    BalancedMedia m' -> h1bind0 (h1bind1 f . BalancedNonMedia) $ f m'


data H0Balanced m0 a
  = H0BalancedNonMedia (H0BalancedNonMedia m0 a)
  | H0BalancedMedia (m0 (H0BalancedNonMedia m0 a))
data H0BalancedNonMedia m0 a
  = H0BalancedEnd a
  | H0BalancedBrackets (H0Balanced m0 (H0Balanced m0 a))

data H1Balanced m1 m0 a
  = H1BalancedNonMedia (H1BalancedNonMedia m1 m0 a)
  | H1BalancedMedia (m1 m0 (H1BalancedNonMedia m1 m0 a))
data H1BalancedNonMedia m1 m0 a
  = H1BalancedEnd (m0 a)
  | H1BalancedBrackets (H1Balanced m1 (H1Balanced m1 m0) a)

data H2Balanced m2 m1 m0 a
  = H2BalancedNonMedia (H2BalancedNonMedia m2 m1 m0 a)
  | H2BalancedMedia (m2 m1 m0 (H2BalancedNonMedia m2 m1 m0 a))
data H2BalancedNonMedia m2 m1 m0 a
  = H2BalancedEnd (m1 m0 a)
  | H2BalancedBrackets (H2Balanced m2 (H2Balanced m2 m1) m0 a)

instance H2Monad H1Balanced where
  
  h2return = H1BalancedMedia . h1map0 (H1BalancedEnd . h0return)
  
  h2bind0 f m = case m of
    H1BalancedNonMedia m' -> case m' of
      H1BalancedEnd m'' -> h1fromMedia $ h1return $ h0map0 f m''
      H1BalancedBrackets m'' ->
        H1BalancedNonMedia $ H1BalancedBrackets $
        h2bind0 (h2map1 h1return . f) m''
    H1BalancedMedia m' ->
      h1fromMedia $ h1map0 (h1bind0 f . H1BalancedNonMedia) m'
  
  h2bind1 f m = case m of
    H1BalancedNonMedia m' -> case m' of
      H1BalancedEnd m'' -> f m''
      H1BalancedBrackets m'' ->
        H1BalancedNonMedia $ H1BalancedBrackets $
        h2map1 (h2bind1 f) m''
    H1BalancedMedia m' ->
      -- TODO: Finish implementing this if possible. If it's not
      -- possible, then we need to reconsider our approach here.
      undefined
  
  h2bind2 f m = case m of
    H1BalancedNonMedia m' -> H1BalancedNonMedia $ case m' of
      H1BalancedEnd m'' -> H1BalancedEnd m''
      H1BalancedBrackets m'' ->
        H1BalancedBrackets $ h2bind2 f $ h2map1 (h2bind2 f) m''
    H1BalancedMedia m' ->
      h2bind0 (h2bind2 f . H1BalancedNonMedia) $ f m'

h1fromMedia ::
  (H1Monad m1, H0Monad m0) =>
  m1 m0 (H1Balanced m1 m0 a) -> H1Balanced m1 m0 a
h1fromMedia = H1BalancedMedia . h1bind0 returnNonMedia
  where
  returnNonMedia ::
    (H1Monad m1, H0Monad m0) =>
    H1Balanced m1 m0 a -> m1 m0 (H1BalancedNonMedia m1 m0 a)
  returnNonMedia m = case m of
    H1BalancedNonMedia m' -> h0return m'
    H1BalancedMedia m' -> m'



-- The type (H2MExpr s m h1 h0) represents a
-- higher-quasiquotation-degree-2 `Map`-based expression for a
-- serializable key type `s` (typically something like `String`), a
-- syntax monad `m`, a type `h1` of stand-ins for degree-1 holes, and
-- a type `h0` of degree-0 holes. These `Map`-based expressions aren't
-- very strongly typed because there's no compile-time guarantee that
-- every key appearing in a hole position will have an entry in the
-- corresponding `Map`.
--
-- We arrived at this by considering an example:
--
-- Suppose we have a pseudocode language where Lisp s-expressions are
-- the syntax monad, the characters ` , represent quasiquotation of
-- degree 0, and the characters ^ $ represent quasiquotation of
-- degree 1.
--
-- A degree-0-quasiquotation-shaped data structure (which we'll also
-- call a degree-1 expression) looks like this, where the symbols `a`
-- and `b` help to indicate how the structure nests and `--`
-- represents a hole:
--
--   `(a `(b ,(a ,(--) a) (b) b) a ,(--) a (a) a)
--
-- The `b` structure nested inside looks like this:
--
--   `(b ,(--) (b) b)
--
-- A degree-1-quasiquotation-shaped data structure (aka a degree-2
-- expression) looks like this:
--
--   ^`(a
--       ^`(b
--           $`(a
--               $`(--)
--               a ,(b (b) b) a ,(b) a `(a) a (a) a)
--           b ,(a) b `(b) b (b) b)
--       a ,(--) a `(a) a (a) a)
--
-- The `b` structure nested inside that one looks like this:
--
--   ^`(b
--       $`(-- ,(b (b) b) ,(b))
--       b ,(--) b `(b) b (b) b)
--
-- This time we have two kinds of holes: An occurrence of , introduces
-- a hole of degree 0 which can be filled with an s-expression (aka a
-- degree-0 expression). An occurrence of $` introduces a hole of
-- degree 1, and occurrences of , inside that hole leave it again. A
-- hole of degree 1 can be filled with a quasiquotation of degree 0
-- (aka an expression of degree 1).
--
-- When we have a hole of degree 1 that hasn't been filled yet, the
-- unquotes inside it are rather orphaned. To tell them apart, we may
-- want to give them `String` labels. When we do, the kind of data
-- that can be inserted into that hole becomes more specific: Instead
-- of just any degree-0 quasiquotation, it should be a degree-0
-- quasiquotation where the degree-0 holes are represented by `String`
-- labels corresponding to the labels of our orphaned unquotes.
--
-- So this means the data type acts as a sort of container of holes,
-- and oftentimes we'll want it to contain strings in those holes.
--
-- We also know a lot about the structure of this data now: For every
-- degree, an expression of that degree is shaped like an s-expression
-- which can contain holes of strictly lower degrees. In the same way,
-- a hole of some degree has orphaned sections containing expressions
-- of every strictly lower degree.
--
-- There's something else that can appear wherever a hole can appear:
-- A *nested expression* of the same or lesser degree. When this
-- nested expression reaches a hole, it resumes the original
-- expression. So when a nested expression appears in our data
-- structure, there's some additional data that appears in the holes
-- within that.
--
-- (In this example, we didn't consider ( ) to be a variant of
-- quasiquotation because we wouldn't have multiple orphaned closing
-- parens to differentiate with labels. However, there should be
-- nothing stopping us from using a label anyway, and hence nothing
-- stopping us from designing a language where the syntax monad is
-- (Writer String) and the characters ( ) represent degree-0
-- quasiquotation.)
--
data H0MExpr s m
  = H0MExprMedia (m (H0MExprNonMedia s m))
data H0MExprNonMedia s m
  = H0MExprLayer0 (H0MExpr s m)
data H1MExpr s m h0
  = H1MExprMedia (m (H1MExprNonMedia s m h0))
data H1MExprNonMedia s m h0
  = H1MExprHole0 h0
  | H1MExprLayer0 (H0MExpr s m)
  | H1MExprLayer1 (H1MExpr s m s)
      (Map s (H1MExpr s m h0))
data H2MExpr s m h1 h0
  = H2MExprMedia (m (H2MExprNonMedia s m h1 h0))
data H2MExprNonMedia s m h1 h0
  = H2MExprHole0 h0
  | H2MExprHole1 h1
      (Map s (H2MExpr s m h1 h0))
  | H2MExprLayer0 (H0MExpr s m)
  | H2MExprLayer1 (H1MExpr s m s)
      (Map s (H2MExpr s m h1 h0))
  | H2MExprLayer2 (H2MExpr s m s s)
      (Map s (H2MExpr s m h1 h0))
      (Map s (H2MExpr s m h1 s))
data H3MExpr s m h2 h1 h0
  = H3MExprMedia (m (H3MExprNonMedia s m h2 h1 h0))
data H3MExprNonMedia s m h2 h1 h0
  = H3MExprHole0 h0
  | H3MExprHole1 h1
      (Map s (H3MExpr s m h2 h1 h0))
  | H3MExprHole2 h2
      (Map s (H3MExpr s m h2 h1 h0))
      (Map s (H3MExpr s m h2 h1 s))
  | H3MExprLayer0 (H0MExpr s m)
  | H3MExprLayer1 (H1MExpr s m s)
      (Map s (H3MExpr s m h2 h1 h0))
  | H3MExprLayer2 (H2MExpr s m s s)
      (Map s (H3MExpr s m h2 h1 h0))
      (Map s (H3MExpr s m h2 h1 s))
  | H3MExprLayer3 (H3MExpr s m s s s)
      (Map s (H3MExpr s m h2 h1 h0))
      (Map s (H3MExpr s m h2 h1 s))
      (Map s (H3MExpr s m h2 s s))

-- The type (HDExpr s m) represents a higher quasiquotation expression
-- of dynamic degree for a serializable key type `s` (typically
-- something like `String`) and a syntax monad `m`. This is even less
-- strongly-typed than the `H0MExpr` family, because this doesn't even
-- statically guarantee that holes will be filled in with expressions
-- of appropriate degree, nor that the holes will have strictly lesser
-- degree than the expression they appear in. These properties must be
-- enforced dynamically to keep the higher quasiquotation structure
-- well-formed. However, this representation will be useful for
-- expressing algorithms that operate on expressions of arbitrary
-- higher quasiquotation degree.
--
-- Note that if any holes appear in a higher quasiquotation expression
-- encoded this way, they must be represented using the same key type
-- that the internal (filled) holes use. So, metadata associated with
-- those holes may need to be tracked in an external `Map`.
--
-- We arrived at this design by conflating the constructors of the
-- `H0MExpr` family so that they could be differentiated using nothing
-- but list length.
--
data HDExpr s m
  = HDExprMedia (m (HDExprNonMedia s m))
data HDExprNonMedia s m
  = HDExprHole s [Map s (HDExpr s m)]
  | HDExprLayer (HDExpr s m) [Map s (HDExpr s m)]

-- The type (H2TExpr m h1 h0) represents a
-- higher-quasiquotation-degree-2 strongly typed expression for a
-- syntax monad `m`, a family of types `h1` for degree-1 holes, and a
-- type `h0` of degree-0 holes.
--
-- We arrived at these by simplifying the `H0MExpr` family to remove
-- all uses of `s`.
--
data H0TExpr m
  = H0TExprMedia (m (H0TExprNonMedia m))
data H0TExprNonMedia m
  = H0TExprLayer0 (H0TExpr m)
data H1TExpr m h0
  = H1TExprMedia (m (H1TExprNonMedia m h0))
data H1TExprNonMedia m h0
  = H1TExprHole0 h0
  | H1TExprLayer0 (H0TExpr m)
  | H1TExprLayer1 (H1TExpr m (H1TExpr m h0))
data H2TExpr m h1 h0
  = H2TExprMedia (m (H2TExprNonMedia m h1 h0))
data H2TExprNonMedia m h1 h0
  = H2TExprHole0 h0
  | H2TExprHole1 (h1 (H2TExpr m h1 h0))
  | H2TExprLayer0 (H0TExpr m)
  | H2TExprLayer1 (H1TExpr m (H2TExpr m h1 h0))
  | H2TExprLayer2 (H2TExpr m (H2TExpr m h1) (H2TExpr m h1 h0))
data H3TExpr m h2 h1 h0
  = H3TExprMedia (m (H3TExprNonMedia m h2 h1 h0))
data H3TExprNonMedia m h2 h1 h0
  = H3TExprHole0 h0
  | H3TExprHole1 (h1 (H3TExpr m h2 h1 h0))
  | H3TExprHole2 (h2 (H3TExpr m h2 h1) (H3TExpr m h2 h1 h0))
  | H3TExprLayer0 (H0TExpr m)
  | H3TExprLayer1 (H1TExpr m (H3TExpr m h2 h1 h0))
  | H3TExprLayer2 (H2TExpr m (H3TExpr m h2 h1) (H3TExpr m h2 h1 h0))
  | H3TExprLayer3
      (H3TExpr m
        (H3TExpr m h2)
        (H3TExpr m h2 h1)
        (H3TExpr m h2 h1 h0))

-- TODO: There's an encouraging resemblance between the definitions of
-- `H1TExpr` and `Balanced`. See if we can make instances like so:
--
--   instance (Monad m) => H0Monad (H1TExpr m)
--   instance (Monad m) => H1Monad (H2TExpr m)
--   instance (Monad m) => H2Monad (H3TExpr m)
