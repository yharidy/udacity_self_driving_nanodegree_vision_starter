import argparse
import glob
import os
import random
import shutil

import yaml

from utils import get_module_logger


def split(source, destination, split_cfg_file=None):
    """
    Create three splits from the processed records. The files should be moved to new folders in the
    same directory. This folder should be named train, val and test.

    args:
        - source [str]: source data directory, contains the processed tf records
        - destination [str]: destination data directory, contains 3 sub folders: train / val / test
    """
    if not os.path.exists(destination):
        os.mkdir(destination)
    if not os.path.exists(os.path.join(destination, 'train')):
        os.mkdir(os.path.join(destination, 'train'))
    if not os.path.exists(os.path.join(destination, 'val')):
        os.mkdir(os.path.join(destination, 'val'))
    if not os.path.exists(os.path.join(destination, 'test')):
        os.mkdir(os.path.join(destination, 'test'))
    if split_cfg_file is not None:
        with open(split_cfg_file, 'r', encoding='utf-8') as f:
            split_cfg = yaml.load(f)
            for file in split_cfg['train']:
                shutil.copy(file, os.path.join(destination, 'train'))
            for file in split_cfg['val']:
                shutil.copy(file, os.path.join(destination, 'val'))
            for file in split_cfg['test']:
                shutil.copy(file, os.path.join(destination, 'test'))
    else:
        files = glob.glob(os.path.join(source, '*.tfrecord'))
        random.shuffle(files)
        n_files = len(files)
        n_train = int(n_files * 0.85)
        n_val = int(n_files * 0.1)
        for i, file in enumerate(files):
            if i < n_train:
                shutil.copy(file, os.path.join(destination, 'train/'))
            elif i < n_train + n_val:
                shutil.copy(file, os.path.join(destination, 'val/'))
            else:
                shutil.copy(file, os.path.join(destination, 'test/'))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Split data into training / validation / testing')
    parser.add_argument('--source', required=True,
                        help='source data directory')
    parser.add_argument('--destination', required=True,
                        help='destination data directory')
    parser.add_argument('--split-cfg-file', required=False,
                        help='destination data directory')
    args = parser.parse_args()

    logger = get_module_logger(__name__)
    logger.info('Creating splits...')
    split(args.source, args.destination)