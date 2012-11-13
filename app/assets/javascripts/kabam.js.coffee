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
  
  getArmlist=(cityId)->
     $.ajax
        url: '/queryarmlist/'+cityId
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
           alert "数据读取有误，请稍后再试。"
        success: (data, textStatus, jqXHR) ->
           $("#arm_list").html data
           armids =  $("#arm_ids").val()
           arr_armid =[]
           arr_armid = armids.split(",") if armids!=''
           arr_ckx = $("input[name='cac']").toArray()
           #alert armids
           $.each arr_ckx,(key,chk)->
              if $.inArray(chk.value,arr_armid)!=-1
                $(chk).attr("checked","checked")

  getWarlist=(cityId)->
     $.ajax
        url: '/querywarlist/'+cityId
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
           alert "数据读取有误，请稍后再试。"
        success: (data, textStatus, jqXHR) ->
           $("#war_list").html data
       

  getDefendlist=(cityId)->
    $.ajax
        url: '/querydefendlist/'+cityId
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
           alert "数据读取有误，请稍后再试。"
        success: (data, textStatus, jqXHR) ->
           $("#defend_list").html data



  updateTrainQueue=() ->
     #更新训练状态
     if $("#train_progress").val()!=undefined && $("#city_id").val()!=undefined
        cityId = $("#city_id").val()
        getQueuetrain cityId       
        getArmlist cityId
        getWarlist cityId
        getDefendlist cityId

   setInterval(updateTrainQueue,_speed)
   true

$ ->
  $("#fighter").change ->
    user_id = $(this).val()   
    if user_id != '' 
      $.ajax
        url: '/citiesforuser/'+user_id
        type: 'GET'
        error: (jqXHR, textStatus, errorThrown) ->
           alert "数据读取有误，请稍后再试。"
        success: (data, textStatus, jqXHR) ->
           $("#acity").html data
    else
      $("#acity").html ""

@choseArm=(id,armtype,obj)->
  armids =  $("#arm_ids").val()
  arr_armid =[]
  arr_armid = armids.split(",") if armids!=''
  idindex = $.inArray(id.toString(),arr_armid)
  if $(obj).attr("checked")=="checked"
     if idindex==-1
       arr_armid.push(id)
       incrArm(armtype)
  else
     if armids.length>0
       delete arr_armid[idindex] if idindex!=-1
       descArm(armtype)
       arr_armid = $.grep arr_armid,(val)-> $.trim(val).length>0
  $("#arm_ids").val arr_armid.join(",")
  showArmResult()
  true

@incrArm=(armtype)->
   arm = $("#arm#{armtype}count")
   armcount = arm.val()
   if armcount=="" then armcount=0 else armcount= parseInt(armcount)
   arm.val armcount+=1 

@descArm=(armtype)->
   arm = $("#arm#{armtype}count")
   armcount= parseInt arm.val()
   arm.val armcount-=1 

@showArmResult=()->
   $("#attackarm").html "出征士兵有：#{$("#arm_ids").val()}<br/>"+"长枪兵共#{$("#arm1count").val()}个<br/>"+"弓箭手共#{$("#arm2count").val()}个<br/>"+"骑兵共#{$("#arm3count").val()}个<br/>"



