import sys
#
#gcd.start(  7,   62)
#gcd.result()=          10

def gcd(a, factor):
    if (a < factor):
        return gcd(factor, a)

    assert (a >= factor)
    if (a % factor == 0):
        return factor;

    return gcd(factor, a % factor)
    

if __name__ == "__main__":
    data = sys.stdin.readlines()
    #gcd.start(  7,   62)
    #gcd.result()=          10
    raw_pairs = data
    i = 0
    while i < len(raw_pairs):
        # (7, 62)
        start = list(map(lambda s: int(s.strip()), raw_pairs[i].split("gcd.start(")[1].split(")")[0].split(",")))
        res = int(raw_pairs[i + 1].split("gcd.result()=")[1].strip())

        print ("start: %s | res: %s" % (start, res))
        assert gcd(start[0], start[1]) == res
        i += 2




