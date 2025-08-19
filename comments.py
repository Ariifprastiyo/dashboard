from hikerapi import Client

cl = Client(token="P0SBEUnlcdFLlBfqxAU3XgFyt9VfFmEV")

media_id = "3292971493661372603"
min_id = None
comments = []
count = 0
while count < 5:
    res, min_id, max_id = cl.media_comments_chunk_v1(media_id, min_id=min_id)
    # print(min_id)
    # print(max_id)
    params = {"id": id, "min_id": min_id, "max_id": max_id}
    print(params)
    comments.extend(res)
    count += 1