$ ->
  _speed=3000
  getQueuetrain=(cityId)->
     $.ajax
        url: '/queryqueuetrain/'+cityId
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
           alert "数据读取有误，请稍后再试。"
        success: (data, textStatus, jqXHR) ->
           $("#train_progress").html data

  updateTrainQueue=() ->
     #更新训练状态
     if $("#train_progress").val()!=undefined && $("#city_id").val()!=undefined
        getQueuetrain $("#city_id").val()

   setInterval(updateTrainQueue,_speed)
   true
