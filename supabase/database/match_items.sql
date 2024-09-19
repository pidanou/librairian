## 2x match_count :  when combining both matches list, after removing duplicates items, there will always be at least match_count items.

create or replace function match_item_by_description (
    query_embedding vector,
    match_threshold float,
    match_count int,
    owner_id uuid
  )
  returns table (
    item_id uuid,
    similarity float
  )
  language sql stable
  security definer set search_path = ''
  as $$
  select
      item.id as item_id,
      1 - (description_embeddings <=> query_embedding) as similarity
    from item
    where description_embeddings <=> query_embedding <= 1 - match_threshold AND item.user_id = owner_id
    order by description_embeddings <=> query_embedding
    limit 2*match_count;
  $$;


CREATE OR REPLACE FUNCTION match_item_by_captions (
    query_embedding vector,
    match_threshold float,
    match_count int,
    owner_id uuid
)
RETURNS TABLE (
    item_id uuid,
    similarity float
)
LANGUAGE sql STABLE
security definer set search_path = ''
AS $$
SELECT DISTINCT ON (attachment.item_id) 
    attachment.item_id AS item_id,
    1 - (captions_embeddings <=> query_embedding) AS similarity
FROM attachment
WHERE captions_embeddings <=> query_embedding <= 1 - match_threshold 
  AND attachment.user_id = owner_id
ORDER BY attachment.item_id, captions_embeddings <=> query_embedding
LIMIT 2*match_count;
$$;

