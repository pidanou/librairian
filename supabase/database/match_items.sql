create or replace function match_item (
    query_embedding vector,
    match_threshold float,
    match_count int,
    owner_id uuid
  )
  returns table (
    item_id uuid,
    description_similarity float
  )
  language sql stable
  as $$
    select
      item.id as item_id,
      1 - (description.embedding <=> query_embedding) as description_similarity
    from item join description on item.id = description.item_id
    where description.embedding <=> query_embedding <= 1 - match_threshold AND item.user_id = owner_id
    order by description.embedding <=> query_embedding
    limit match_count;
  $$;
