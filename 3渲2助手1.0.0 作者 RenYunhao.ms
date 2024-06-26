/*
 SpritesRender 基于下面的版本迭代开发而来
 type: scrited Utility
 author: Denys Almaral (http://www.denysalmaral.com)
 instrunctions: http://www.denysalmaral.com/2012/04/px-spritesrender-3ds-max-scripted.html
 license: FREE
*/

panelWidth = 240
buttonWidth = 100
buttonHeight = 30

rollout spritesRender "3渲2助手1.0.0 作者：RenYunhao" 
(
	local cameraNode = undefined
	local root = undefined
	local bm = undefined

	local directionDigit = 0
	local frameDigit = 0
	
	function CameraFilter obj = (isKindOf obj camera)
	
	group "目标"
	(
		pickbutton btnPickObject "选择根物体" width:buttonWidth height:buttonHeight message:"选择你要渲染的根物体"
		label lblObject "无" 
		pickbutton btnPickCamera "选择摄像机" width:buttonWidth height:buttonHeight message:"选择你要渲染的摄像机" filter:CameraFilter
		label lblCamera "无"
	)

	group "渲染"
	(
		dropdownlist ddlDirection "" items:#("四方向","八方向","自定义方向数") selection:2  width:100 
		spinner spnAngCount "" pos:[126, ddlDirection.pos.y + 2] fieldwidth:40 range:[1,360,8] type:#integer scale:1 enabled:false
		spinner spnFrameDelta "每N帧：" pos:[133, ddlDirection.pos.y + 30] fieldwidth:40 range:[1,100,1] type:#integer scale:1 enabled:false
		radiobuttons radRenderType labels:#("单帧", "活动时间段", "范围", "指定帧") pos:[12, spnFrameDelta.pos.y + 20] columns:1 offsets:#([0,5], [0,10], [0,15], [0,20]) 
		label lblActiveFrameRange "0 - 100" pos:[150, radRenderType.pos.y + 20] width:40 
		spinner spnRangeFrom "" pos:[70, lblActiveFrameRange.pos.y + 20] fieldwidth:59 range:[0,999,0] type:#integer scale:1
		label lblFromTo "至" pos:[146, spnRangeFrom.pos.y] width:20 
		spinner spnRangeTo "" pos:[158, spnRangeFrom.pos.y] fieldwidth:59 range:[1,1000,1] type:#integer scale:1
		edittext edtSpecificFrame text:"1,3,5-12" pos:[70, spnRangeTo.pos.y + 20] width:160

		spinner spnFrameDigit "输出文件名中帧填充位：" fieldwidth:40 range:[1,6,1] type:#integer scale:1
	
		button btnRender "开始渲染" width:buttonWidth height:buttonHeight enabled:false 
		label lblTip "!!!渲染参数是当前的渲染输出设置!!!" align:#center
	)
	
	function RenderFrame frameIndex =
	(
		if cameraNode != undefined then	
		(
			bm = Render OutPutfile:RendOutPutFileName camera:cameraNode frame:frameIndex quiet:true vfb:true pos:#vfb_upper_left
		)
		else
		(
			bm = Render OutPutfile:RendOutPutFileName frame:frameIndex quiet:true 
		)
		unDisplay bm
		Result = bm
	)
	
	function ModifyName fileName direction frameIndex =
	(
		local ext = (GetFilenameType fileName)		
		local newName = (GetFilenamePath fileName) + "/" + (GetFileNameFile fileName)

		local formatPattern = "0" + (directionDigit as string) + "d"
		local directionText = formattedprint direction format: formatPattern

		if frameIndex != unsupplied then
		(
			local frameFormatPattern = "0" + (frameDigit as string) + "d"
			local frameText = formattedprint frameIndex format: frameFormatPattern
			newName = newName + "_" + directionText + "_" + frameText + ext
		)
		else
		(		
			newName = newName + "_" + directionText + "_" + ext		
		)
		print ("newName " + newName)
		Result = newName
	)

	on ddlDirection selected selectionIndex do
	(
		if (selectionIndex == 1) then
		(
			spnAngCount.value = 4;
		)
		else if (selectionIndex == 2) then
		(
			spnAngCount.value = 8;
		)
		spnAngCount.enabled = selectionIndex == 3
	)

	on btnPickObject picked obj do
	(
		lblObject.Caption = obj.name
		root = obj
		if cameraNode != undefined then btnRender.enabled = true
	)

	on btnPickCamera picked obj do
	(
		lblCamera.Caption = obj.name
		cameraNode = obj
		if root != undefined then btnRender.enabled = true
	)

	on radRenderType changed state do
	(
		if radRenderType.state == 1 or radRenderType.state == 4 then
		(
			spnFrameDelta.enabled = false
		)
		else
		(
			spnFrameDelta.enabled = true
		)
	)

	on btnRender pressed do
	(
		animButtonState = false
	    local nameBak = RendOutPutFileName
		local rotBak = Root.rotation	
		local rotz = eulerAngles 0 0 (-360/spnAngCount.value)
				
		--记录RenderElement的输出文件名
		local renderElementMgr = MaxOps.GetCurRenderElementMgr()
		local renderElementNameCache = #()		
		renderElementNameCache.count = renderElementMgr.NumRenderElements()		
		for i = 0 to renderElementNameCache.count - 1 do 
		(
			renderElementNameCache[i+1] = renderElementMgr.GetRenderElementFilename i
		)
		
		local directionCount = spnAngCount.value
		directionDigit = 0;
		while (directionCount > 0) do
		(
			directionCount /= 10
			directionDigit += 1
		)
		frameDigit = spnFrameDigit.value

		local rotateCount = 0;
		if (spnAngCount.value == 4) then
		(
			--四方向实际只需要渲染三个方向，因为左右对称
			rotateCount = 3;
		)
		else if (spnAngCount.value == 8) then
		(
			--八方向实际只需要渲染五个方向，因为左右对称
			rotateCount = 5;
		)
		else
		(
			rotateCount = spnAngCount.value
		)

		print rotateCount

		for i = 1 to rotateCount do
		(
			if radRenderType.state == 1 then
			(
				-- 设置RenderElement输出文件名
				local frameIndex = animationRange.start.frame as integer
				for renderElementIndex = 1 to renderElementNameCache.count do 
				(
					local renderElementFileName = ModifyName renderElementNameCache[renderElementIndex] i frameIndex
					renderElementMgr.SetRenderElementFilename renderElementIndex renderElementFileName
				)
				
				-- 渲染当前帧
				RendOutPutFileName = ModifyName nameBak i frameIndex
				RenderFrame frameIndex
			)
			else if (radRenderType.state == 2) then
			(
				local frameStart = animationRange.start.frame as integer
				local frameEnd = animationRange.end.frame as integer
				for frameIndex = frameStart to frameEnd by spnFrameDelta.value do
				(
					-- 设置RenderElement输出文件名
					for renderElementIndex = 1 to renderElementNameCache.count do 
					(
						local renderElementFileName = ModifyName renderElementNameCache[renderElementIndex] i frameIndex
						renderElementMgr.SetRenderElementFilename renderElementIndex renderElementFileName
					)
					
					-- 渲染当前帧
					RendOutPutFileName = ModifyName nameBak i frameIndex
					RenderFrame frameIndex
				)
			)
			else if (radRenderType.state == 3) then
			(
				local frameStart = spnRangeFrom.value
				local frameEnd = spnRangeTo.value
				for frameIndex = frameStart to frameEnd by spnFrameDelta.value do
				(
					-- 设置RenderElement输出文件名
					for renderElementIndex = 1 to renderElementNameCache.count do 
					(
						local renderElementFileName = ModifyName renderElementNameCache[renderElementIndex] i frameIndex
						renderElementMgr.SetRenderElementFilename renderElementIndex renderElementFileName
					)
					
					-- 渲染当前帧
					RendOutPutFileName = ModifyName nameBak i frameIndex
					RenderFrame frameIndex
				)

			)
			else if (radRenderType.state == 4) then
			(
				local frameArray = #()
				print edtSpecificFrame.text
				local splits = filterString edtSpecificFrame.text ","
				for frameText in splits do 
				(
					local hasDash = findString frameText "-" != undefined
					if hasDash then
					(
						local rangeSplits = filterString frameText "-"
						local rangeStart = rangeSplits[1] as integer
						local rangeEnd = rangeSplits[2] as integer

						for i = rangeStart to rangeEnd do
						(
							append frameArray i
						)
					)
					else
					(
						local frameValue = frameText as integer
						append frameArray frameValue
					)
				)

				for frameIndex in frameArray do
				(
					-- 设置RenderElement输出文件名
					for renderElementIndex = 1 to renderElementNameCache.count do 
					(
						local renderElementFileName = ModifyName renderElementNameCache[renderElementIndex] i frameIndex
						renderElementMgr.SetRenderElementFilename renderElementIndex renderElementFileName
					)
					
					-- 渲染当前帧
					RendOutPutFileName = ModifyName nameBak i frameIndex
					RenderFrame frameIndex
				)
			)
			Rotate root rotz
		)

		RendOutPutFileName = nameBak
		Root.rotation = rotBak
		for i=0 to renderElementNameCache.count-1 do 
		(
			renderElementMgr.SetRenderElementFilename i renderElementNameCache[i+1]
		)
	)

	function updateTimeRange = 
	(
		lblActiveFrameRange.text = (animationRange.start.frame as integer) as string + " - " + (animationRange.end.frame as integer) as string
	)

	on spritesRender open do
	(
		updateTimeRange()
	)
)

createDialog spritesRender panelWidth 370

registerTimeCallback spritesRender.updateTimeRange