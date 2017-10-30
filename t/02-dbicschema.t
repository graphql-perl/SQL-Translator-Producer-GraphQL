use strict;
use Test::More 0.98;
use File::Spec;
use lib 't/lib-dbicschema';
use Schema;

use_ok 'SQL::Translator::Producer::GraphQL', 'schema_dbic2graphql';

my $expected = join '', <DATA>;
my $dbic_class = 'Schema';
my $got = schema_dbic2graphql($dbic_class->connect)->to_doc;
#open my $fh, '>', 'tf'; print $fh $got; # uncomment to regenerate
is $got, $expected;

done_testing;

__DATA__
type Blog {
  blog_tags: [BlogTag]
  content: String!
  created_time: String!
  id: Int!
  location: String
  subtitle: String
  tags: [BlogTag]
  timestamp: DateTime!
  title: String!
}

input BlogInput {
  content: String!
  created_time: String!
  location: String
  subtitle: String
  timestamp: DateTime!
  title: String!
}

type BlogTag {
  blog: Blog
  id: Int!
  name: String!
}

input BlogTagInput {
  name: String!
}

scalar DateTime

type Mutation {
  createBlog(input: BlogInput!): Blog
  createBlogTag(blog_id: Int!, input: BlogTagInput!): BlogTag
  createPhoto(input: PhotoInput!, photoset_id: String!): Photo
  createPhotoset(input: PhotosetInput!, photo_id: String!): Photoset
  deleteBlog(id: Int!): Boolean
  deleteBlogTag(id: Int!): Boolean
  deletePhoto(id: String!): Boolean
  deletePhotoset(id: String!): Boolean
  updateBlog(id: Int!, input: BlogInput!): Blog
  updateBlogTag(id: Int!, input: BlogTagInput!): BlogTag
  updatePhoto(id: String!, input: PhotoInput!): Photo
  updatePhotoset(id: String!, input: PhotosetInput!): Photoset
}

type Photo {
  country: String
  description: String
  id: String!
  idx: Int
  is_glen: String
  isprimary: String
  large: String
  lat: String
  locality: String
  lon: String
  medium: String
  original: String
  original_url: String
  photoset: Photoset
  photosets: [Photoset]
  region: String
  set: Photoset
  small: String
  square: String
  taken: DateTime
  thumbnail: String
}

input PhotoInput {
  country: String
  description: String
  idx: Int
  is_glen: String
  isprimary: String
  large: String
  lat: String
  locality: String
  lon: String
  medium: String
  original: String
  original_url: String
  region: String
  small: String
  square: String
  taken: DateTime
  thumbnail: String
}

type Photoset {
  can_comment: Int
  count_comments: Int
  count_views: Int
  date_create: Int
  date_update: Int
  description: String!
  farm: Int!
  id: String!
  idx: Int!
  needs_interstitial: Int
  photos: [Photo]
  primary: Photo
  primary_photo: Photo
  secret: String!
  server: String!
  timestamp: DateTime!
  title: String!
  videos: Int
  visibility_can_see_set: Int
}

input PhotosetInput {
  can_comment: Int
  count_comments: Int
  count_views: Int
  date_create: Int
  date_update: Int
  description: String!
  farm: Int!
  idx: Int!
  needs_interstitial: Int
  secret: String!
  server: String!
  timestamp: DateTime!
  title: String!
  videos: Int
  visibility_can_see_set: Int
}

type Query {
  blogByContent(content: String!): [Blog]
  blogByCreated_time(created_time: String!): [Blog]
  blogById(id: Int!): Blog
  blogByLocation(location: String!): [Blog]
  blogBySubtitle(subtitle: String!): [Blog]
  blogByTimestamp(timestamp: DateTime!): [Blog]
  blogByTitle(title: String!): [Blog]
  blogtagById(id: Int!): BlogTag
  blogtagByName(name: String!): [BlogTag]
  photoByCountry(country: String!): [Photo]
  photoByDescription(description: String!): [Photo]
  photoById(id: String!): Photo
  photoByIdx(idx: Int!): [Photo]
  photoByIs_glen(is_glen: String!): [Photo]
  photoByIsprimary(isprimary: String!): [Photo]
  photoByLarge(large: String!): [Photo]
  photoByLat(lat: String!): [Photo]
  photoByLocality(locality: String!): [Photo]
  photoByLon(lon: String!): [Photo]
  photoByMedium(medium: String!): [Photo]
  photoByOriginal(original: String!): [Photo]
  photoByOriginal_url(original_url: String!): [Photo]
  photoByRegion(region: String!): [Photo]
  photoBySmall(small: String!): [Photo]
  photoBySquare(square: String!): [Photo]
  photoByTaken(taken: DateTime!): [Photo]
  photoByThumbnail(thumbnail: String!): [Photo]
  photosetByCan_comment(can_comment: Int!): [Photoset]
  photosetByCount_comments(count_comments: Int!): [Photoset]
  photosetByCount_views(count_views: Int!): [Photoset]
  photosetByDate_create(date_create: Int!): [Photoset]
  photosetByDate_update(date_update: Int!): [Photoset]
  photosetByDescription(description: String!): [Photoset]
  photosetByFarm(farm: Int!): [Photoset]
  photosetById(id: String!): Photoset
  photosetByIdx(idx: Int!): [Photoset]
  photosetByNeeds_interstitial(needs_interstitial: Int!): [Photoset]
  photosetBySecret(secret: String!): [Photoset]
  photosetByServer(server: String!): [Photoset]
  photosetByTimestamp(timestamp: DateTime!): [Photoset]
  photosetByTitle(title: String!): [Photoset]
  photosetByVideos(videos: Int!): [Photoset]
  photosetByVisibility_can_see_set(visibility_can_see_set: Int!): [Photoset]
}
