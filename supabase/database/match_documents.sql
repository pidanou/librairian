create or replace function match_file (
    query_embedding vector,
    match_threshold float,
    match_count int,
    owner_id uuid
  )
  returns table (
    file_id uuid,
    summary_similarity float,
    description_similarity float
  )
  language sql stable
  as $$
    select
      file.id as file_id,
      1 - (summary.embedding <=> query_embedding) as summary_similarity,
      1 - (description.embedding <=> query_embedding) as description_similarity
    from file join summary on file.id = summary.file_id join description on file.id = description.file_id
    where (summary.embedding <=> query_embedding < 1 - match_threshold OR description.embedding <=> query_embedding < 1 - match_threshold) AND file.user_id = owner_id
    order by (summary.embedding <=> query_embedding) + (description.embedding <=> query_embedding)
    limit match_count;
  $$;
