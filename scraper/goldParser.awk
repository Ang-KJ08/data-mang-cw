BEGIN{
    spot=""; change=""; perf30="", perf1y=""
}

/Gold Price Today/{
    getline
    gsub(/<[^>]+>/,"",&0)

    if ($0 ~ /[0-9]+\.[0-9]+/){
        spot_price = $0
    }

    getline
    gsub(/<[^>]+>/,"",&0)
    change_rate = $0

    getline
    gsub(/<[^>]+>/,"",&0)
    perf_30 = $0

    getline
    gsub(/<[^>]+>/,"",&0)
    perf_1y = $0
}

/"data-current-price"/{
    gsub(/[^0-9.]/,"",$0)
    spot=$0
}

/"data-change-percent"/{
    gsub(/[^0-9.-]/,"",$0)
    change=$0
}

/"data-30d"/{
    gsub(/[^0-9.-]/,"",$0)
    perf30=$0
}

/"data-1y"/{
    gsub(/[^0-9.-]/,"",$0)
    perf1y=$0
}

END{
    print spot "," change "," perf30 "," perf1y
