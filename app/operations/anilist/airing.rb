module Anilist
  class Airing < Base  
    def execute
      @result = Anilist::Result.new(client.query(Query, **graphql_params))
    end

    Query = Anilist::Client.parse <<-GRAPHQL
        query (
          $page: Int = 1
          $type: MediaType
          $isAdult: Boolean = false
          $search: String
          $format: [MediaFormat]
          $countryOfOrigin: CountryCode
          $source: MediaSource
          $season: MediaSeason
          $seasonYear: Int
          $year: String
          $onList: Boolean
          $yearLesser: FuzzyDateInt
          $yearGreater: FuzzyDateInt
          $episodeLesser: Int
          $episodeGreater: Int
          $durationLesser: Int
          $durationGreater: Int
          $licensedBy: [Int]
          $isLicensed: Boolean
          $genres: [String]
          $excludedGenres: [String]
          $tags: [String]
          $excludedTags: [String]
          $minimumTagRank: Int
          $sort: [MediaSort] = [POPULARITY_DESC, SCORE_DESC]
        ) {
          Page(page: $page, perPage: 20) {
            pageInfo {
              total
              perPage
              currentPage
              lastPage
              hasNextPage
            }
            media(
              type: $type
              season: $season
              format_in: $format
              status: RELEASING
              countryOfOrigin: $countryOfOrigin
              source: $source
              search: $search
              onList: $onList
              seasonYear: $seasonYear
              startDate_like: $year
              startDate_lesser: $yearLesser
              startDate_greater: $yearGreater
              episodes_lesser: $episodeLesser
              episodes_greater: $episodeGreater
              duration_lesser: $durationLesser
              duration_greater: $durationGreater
              licensedById_in: $licensedBy
              isLicensed: $isLicensed
              genre_in: $genres
              genre_not_in: $excludedGenres
              tag_in: $tags
              tag_not_in: $excludedTags
              minimumTagRank: $minimumTagRank
              sort: $sort
              isAdult: $isAdult
            ) {
              id
              title {
                romaji
                english
                native
                userPreferred
              }
              coverImage {
                extraLarge
                large
                color
              }
              startDate {
                year
                month
                day
              }
              endDate {
                year
                month
                day
              }
              bannerImage
              season
              seasonYear
              description
              type
              format
              status(version: 2)
              episodes
              duration
              chapters
              volumes
              genres
              isAdult
              averageScore
              popularity
              nextAiringEpisode {
                airingAt
                timeUntilAiring
                episode
              }
              mediaListEntry {
                id
                status
              }
              relations {
                nodes {
                  id
                  type
                  format
                  title {
                    romaji
                    english
                    native
                    userPreferred
                  }
                }
              }
              studios(isMain: true) {
                edges {
                  isMain
                  node {
                    id
                    name
                  }
                }
              }
            }
          }
        }
      GRAPHQL
  end
end
