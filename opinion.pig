raw_data = load '/opinion_segregation/tweets.csv' using PigStorage(',');

get_details = foreach raw_data generate $0 as id,$1 as text;

tokens = foreach get_details generate id,text,FLATTEN(TOKENIZE(text)) as words;

dictionary = load '/opinion_segregation/Dictionary.txt' using PigStorage('\t') as (word:chararray,rating:int);

word_ratings = join tokens by words left outer, dictionary by word using 'replicated';
describe word_ratings;

ratings = foreach word_ratings generate tokens::id as id,tokens::text as text,dictionary::rating as rating; 

group_words = group ratings by (id,text);

avg_ratings = foreach group_words generate group,AVG(ratings.rating) as tweet_rating;

positive_tweets = filter avg_ratings by tweet_rating > 0;

negative_tweets = filter avg_ratings by tweet_rating < 0;

store positive_tweets INTO '/opinion_segregation/positive_tweets' using PigStorage(',');

store negative_tweets INTO '/opinion_segregation/negative_tweets' using PigStorage(',');



