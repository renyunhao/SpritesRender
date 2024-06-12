-- 创建一个函数来导出单个对象为FBX文件
fn exportObjectToFbx obj filePath = (
    -- 将对象的位置归零
    obj.position = [0,0,0]
    -- 构建FBX文件路径
	local folderPath = filePath + fileNameWithoutExtension + "_Export\\";

	-- 检查文件夹是否存在，如果不存在则创建
	if not (doesFileExist folderPath) then (
		makedir folderPath
	)

    local fbxFilePath = folderPath + obj.name + ".fbx"
	print "导出FBX：" + fbxFilePath
    -- 导出对象为FBX文件
    exportFile fbxFilePath #noPrompt selectedObjects:obj using:FBXEXP
)

fileNameWithoutExtension = getFilenameFile maxFileName

-- 遍历场景中的所有对象
for obj in objects do (
    -- 如果对象是一个可移动的对象（如几何体或者带有变换的对象）
    if isProperty obj #position do (
        -- 调用函数导出对象为FBX文件，传入当前文件夹路径作为导出路径
        exportObjectToFbx obj maxFilePath
    )
)
