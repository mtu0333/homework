#!/usr/bin/env python
# -*- coding: utf-8 -*-
import sys
import random

import helper as hp

def partition(items, lo, hi):
    i, j = lo, hi+1
    piv = items[lo]
    while True:
        while True:
            i += 1
            if items[i] < piv:
                if i == hi:
                    break
            else:
                break
        while True:
            j -= 1
            if piv < items[j]:
                if j == lo:
                    break
            else:
                break
        if i >= j:
            break
        items[i], items[j] = items[j], items[i]
    items[lo], items[j] = items[j], items[lo]
    return j

def quick_sort(items, lo, hi):
    if hi <= lo:
        return
    j = partition(items, lo, hi)
    quick_sort(items, lo, j-1)
    quick_sort(items, j+1, hi)

def quick3_sort(items, lo, hi):
    """
    lo ... lt-1 smaller ones
    lt ... gt   equal ones
    gt+1 ... hi bigger ones

    during sort
    i ... gt    the unsorted ones
    """
    if hi <= lo:
        return
    lt = lo
    i = lo + 1
    gt = hi
    piv = items[lo]
    while i <= gt:
        item = items[i]
        if item < piv:
            items[i], items[lt] = items[lt], items[i]
            i += 1
            lt += 1
        elif item > piv:
            items[i], items[gt] = items[gt], items[i]
            gt -= 1
        else:
            i += 1
    quick3_sort(items, lo, lt-1)
    quick3_sort(items, gt+1, hi)

if __name__ == '__main__':
    items = [random.randint(1, 100) for _ in xrange(10)]
    print items
    quick3_sort(items, 0, len(items)-1)
    print items
