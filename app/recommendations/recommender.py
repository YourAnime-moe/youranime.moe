import pandas as pd
import pickle


class Recommender:
    def __init__(self, save_file=None, randomize=False, **kwargs):
        self._save_file = save_file

        # Allow several data sets
        for kw in kwargs.keys():
            if kw.endswith('_data'):
                data_set_filename = kwargs[kw]
                attr_name = '_' + kw.split('_data')[0]
                data_set = Recommender._set_data_set(data_set_filename, randomize)
                self.__setattr__(attr_name, data_set)

    def data(self, name):
        return self.__getattribute__('_' + name)

    def save(self, mode='wb', **kwargs):
        with open(self._save_file, mode) as file:
            return pickle.dump(self, file, **kwargs)

    def split_data(self, name, first):
        data = self.data(name)[:first]
        return self.__setattr__('_' + name, data)

    @staticmethod
    def _set_data_set(filename, randomize):
        data_set = pd.read_csv(filename)
        if randomize:
            data_set = data_set.sample(frac=1)
        return data_set

    @staticmethod
    def load(filename, mode='rb', **kwargs):
        with open(filename, mode) as file:
            return pickle.load(file, **kwargs)
