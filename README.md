# ES_Sliced_Scroll

Elasticsearch provides scrollAPI for retrieving large numbers of results (or even all results) from a single search request, in much the same way as you would use a cursor on a traditional database. Unfortunately, in sequential manner, single scroll API invocation takes more than 24 hours to retrieve huge data data ranging from millions to billions.


