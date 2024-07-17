create or replace function match_file (
    query_embedding vector,
    match_threshold float,
    match_count int,
    owner_id uuid
  )
  returns table (
    file_id uuid,
    description_similarity float
  )
  language sql stable
  as $$
    select
      file.id as file_id,
      1 - (description.embedding <=> query_embedding) as description_similarity
    from file join description on file.id = description.file_id
    where description.embedding <=> query_embedding < 1 - match_threshold AND file.user_id = owner_id
    order by description.embedding <=> query_embedding
    limit match_count;
  $$;
