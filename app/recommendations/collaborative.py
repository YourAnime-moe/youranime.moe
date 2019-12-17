from collections import defaultdict as dd
from recommender import Recommender
from surprise import Reader, Dataset
from surprise.model_selection import KFold


class CollaborativeRecommender(Recommender):
    def __init__(self,
                 algorithm_class,
                 ratings_data,
                 series_data,
                 save_file='~/.tanoshimu/collaborative.dump',
                 randomize=True,
                 rating_range=(1, 10),
                 learn_on=None,
                 take_the_first=None):
        # Set the algorithm
        self._algorithm = algorithm_class()

        # Initialize the recommender
        super().__init__(save_file=save_file,
                         randomize=randomize,
                         ratings_data=ratings_data,
                         anime_data=series_data)

        # Get the first x
        if take_the_first is not None:
            self.split_data('ratings', take_the_first)

        # Setup model
        reader = Reader(rating_scale=rating_range)
        if learn_on is None:
            learn_on = ['user_id', 'anime_id', 'rating']

        print(self.data('ratings'))
        self._sdata = Dataset.load_from_df(self.data('ratings')[learn_on], reader)
        self._predictions = dict()

    def train(self, count=10):
        print("Creating train set...")
        train_set = self._sdata.build_full_trainset()

        print("Training model...")
        self._algorithm.fit(train_set)

        print("Creating test set...")
        test_set = train_set.build_anti_testset()

        print("Creating predictions...")
        predictions = self._algorithm.test(test_set)

        print("Getting %d predictions..." % count)
        top_n = self._predict(count=count, predictions=predictions)
        for user_id, user_ratings in top_n.items():
            self._predictions[user_id] = [iid for (iid, _) in user_ratings]

        return len(self._predictions)

    def recommend(self, user_id, show_field='title'):
        if not self.trained():
            return None

        try:
            series_id = self._predictions[user_id]
        except KeyError:
            print('This user id %s has not made any ratings yet!' % user_id)
            return None

        if show_field is None:
            return series_id

        return list(self.anime()[self.anime()['anime_id'].isin(series_id)][show_field])

    def anime(self):
        return self.__getattribute__('_anime')

    def ratings(self):
        return self.__getattribute__('_ratings')

    def trained(self):
        return self._predictions is not None

    def _predict(self, count=10, predictions=None):
        top_n = dd(list)
        for user_id, anime_id, true_r, estimation, _ in predictions:
            top_n[user_id].append((anime_id, estimation))

        for user_id, user_ratings in top_n.items():
            user_ratings.sort(key=lambda x: x[1], reverse=True)
            top_n[user_id] = user_ratings[:count]

        return top_n


