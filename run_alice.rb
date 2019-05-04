def command_line(cmdLine)
	puts cmdLine
	system cmdLine
end
def camera_init(base_dir,bin_dir,src_image_dir)
	binName = bin_dir + "/aliceVision_cameraInit"

	dstDir = base_dir + "/00_CameraInit/"
	cmdLine = binName
	cmdLine = cmdLine + " --defaultFieldOfView 45.0 --verboseLevel info --sensorDatabase \"\" --allowSingleView 1"
	cmdLine = cmdLine + " --imageFolder \"" + src_image_dir + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "cameraInit.sfm\""

	command_line(cmdLine)
end

def feature_extraction(base_dir,bin_dir, num_images)
	srcSfm = base_dir + "/00_CameraInit/cameraInit.sfm"

	binName = bin_dir + "/aliceVision_featureExtraction"

	dstDir = base_dir + "/01_FeatureExtraction/"

	cmdLine = binName
	cmdLine = cmdLine + " --describerTypes sift --forceCpuExtraction True --verboseLevel info --describerPreset normal"
	cmdLine = cmdLine + " --rangeStart 0 --rangeSize " + num_images.to_s
	cmdLine = cmdLine + " --input \"" + srcSfm + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "\""
	
	command_line(cmdLine)
end

def image_matching(base_dir,bin_dir)
	srcSfm = base_dir + "/00_CameraInit/cameraInit.sfm"
	srcFeatures = base_dir + "/01_FeatureExtraction/"
	dstMatches = base_dir + "/02_ImageMatching/imageMatches.txt"

	binName = bin_dir + "/aliceVision_imageMatching"

	cmdLine = binName
	cmdLine = cmdLine + " --minNbImages 200 --tree "" --maxDescriptors 500 --verboseLevel info --weights "" --nbMatches 50"
	cmdLine = cmdLine + " --input \"" + srcSfm + "\""
	cmdLine = cmdLine + " --featuresFolder \"" + srcFeatures + "\""
	cmdLine = cmdLine + " --output \"" + dstMatches + "\""
	
	command_line(cmdLine)
end

def feature_matching(base_dir,bin_dir)
	srcSfm = base_dir + "/00_CameraInit/cameraInit.sfm"
	srcFeatures = base_dir + "/01_FeatureExtraction/"
	srcImageMatches = base_dir + "/02_ImageMatching/imageMatches.txt"
	dstMatches = base_dir + "/03_FeatureMatching"

	binName = bin_dir + "/aliceVision_featureMatching"

	cmdLine = binName
	cmdLine = cmdLine + " --verboseLevel info --describerTypes sift --maxMatches 0 --exportDebugFiles False --savePutativeMatches False --guidedMatching False"
	cmdLine = cmdLine + " --geometricEstimator acransac --geometricFilterType fundamental_matrix --maxIteration 2048 --distanceRatio 0.8"
	cmdLine = cmdLine + " --photometricMatchingMethod ANN_L2"
	cmdLine = cmdLine + " --imagePairsList \"" + srcImageMatches + "\""
	cmdLine = cmdLine + " --input \"" + srcSfm + "\""
	cmdLine = cmdLine + " --featuresFolders \"" + srcFeatures + "\""
	cmdLine = cmdLine + " --output \"" + dstMatches + "\""

	command_line(cmdLine)
end

def structure_from_motion(base_dir,bin_dir)
	srcSfm = base_dir + "/00_CameraInit/cameraInit.sfm"
	srcFeatures = base_dir + "/01_FeatureExtraction/"
	srcImageMatches = base_dir + "/02_ImageMatching/imageMatches.txt"
	srcMatches = base_dir + "/03_FeatureMatching"
	dstDir = base_dir + "/04_StructureFromMotion"

	binName = bin_dir + "/aliceVision_incrementalSfm"

	cmdLine = binName
	cmdLine = cmdLine + " --minAngleForLandmark 2.0 --minNumberOfObservationsForTriangulation 2 --maxAngleInitialPair 40.0 --maxNumberOfMatches 0 --localizerEstimator acransac --describerTypes sift --lockScenePreviouslyReconstructed False --localBAGraphDistance 1"
	cmdLine = cmdLine + " --initialPairA "" --initialPairB "" --interFileExtension .ply --useLocalBA True"
	cmdLine = cmdLine + " --minInputTrackLength 2 --useOnlyMatchesFromInputFolder False --verboseLevel info --minAngleForTriangulation 3.0 --maxReprojectionError 4.0 --minAngleInitialPair 5.0"
	
	cmdLine = cmdLine + " --input \"" + srcSfm + "\""
	cmdLine = cmdLine + " --featuresFolders \"" + srcFeatures + "\""
	cmdLine = cmdLine + " --matchesFolders \"" + srcMatches + "\""
	cmdLine = cmdLine + " --outputViewsAndPoses \"" + dstDir + "/cameras.sfm\""
	cmdLine = cmdLine + " --extraInfoFolder \"" + dstDir + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "/bundle.sfm\""
	
	command_line(cmdLine)
end

def prepare_dense_scene(base_dir,bin_dir)
	#srcSfm = base_dir + "/04_StructureFromMotion/cameras.sfm"
	srcSfm = base_dir + "/04_StructureFromMotion/bundle.sfm"
	dstDir = base_dir + "/05_PrepareDenseScene"

	binName = bin_dir + "/aliceVision_prepareDenseScene"

	cmdLine = binName
	cmdLine = cmdLine + " --verboseLevel info"
	cmdLine = cmdLine + " --input \"" + srcSfm + "\""
	cmdLine = cmdLine + " --output \"" + dstDir +"\""
	
	command_line(cmdLine)
end

def camera_connection(base_dir,bin_dir)
	srcIni = base_dir + "/05_PrepareDenseScene/mvs.ini"

	# This step kindof breaks the directory structure. Tt creates
	# a camsPairsMatrixFromSeeds.bin file in in the same file as mvs.ini
	binName = bin_dir + "/aliceVision_cameraConnection"

	cmdLine = binName
	cmdLine = cmdLine + " --verboseLevel info"
	cmdLine = cmdLine + " --ini \"" + srcIni + "\""

	command_line(cmdLine)
end

def depth_map(base_dir,bin_dir,num_images,groupSize)
	numGroups = (num_images + (groupSize-1))/groupSize

	srcIni = base_dir + "/05_PrepareDenseScene/mvs.ini"
	binName = bin_dir + "/aliceVision_depthMapEstimation"
	dstDir = base_dir + "/07_DepthMap"

	cmdLine = binName
	cmdLine = cmdLine + " --sgmGammaC 5.5 --sgmWSH 4 --refineGammaP 8.0 --refineSigma 15 --refineNSamplesHalf 150 --sgmMaxTCams 10 --refineWSH 3 --downscale 2 --refineMaxTCams 6 --verboseLevel info --refineGammaC 15.5 --sgmGammaP 8.0"
	cmdLine = cmdLine + " --refineNiters 100 --refineNDepthsToRefine 31 --refineUseTcOrRcPixSize False"
	
	cmdLine = cmdLine + " --ini \"" + srcIni + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "\""


	for groupIter in 0..numGroups do
		groupStart = groupSize * groupIter
		groupSize = [groupSize,(num_images - groupStart)].min
		puts "DepthMap Group #{groupIter}/#{numGroups}: #{groupStart}, #{groupSize}"

		cmd = cmdLine + " --rangeStart #{groupStart} --rangeSize #{groupSize}"
		command_line(cmd)
	end
end

def depth_map_filter(base_dir,bin_dir)
	binName = bin_dir + "/aliceVision_depthMapFiltering"
	dstDir = base_dir + "/08_DepthMapFilter"
	srcIni = base_dir + "/05_PrepareDenseScene/mvs.ini"
	srcDepthDir = base_dir + "/07_DepthMap"

	cmdLine = binName
	cmdLine = cmdLine + " --minNumOfConsistensCamsWithLowSimilarity 4"
	cmdLine = cmdLine + " --minNumOfConsistensCams 3 --verboseLevel info --pixSizeBall 0"
	cmdLine = cmdLine + " --pixSizeBallWithLowSimilarity 0 --nNearestCams 10"

	cmdLine = cmdLine + " --ini \"" + srcIni + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "\""
	cmdLine = cmdLine + " --depthMapFolder \"" + srcDepthDir + "\""

	command_line(cmdLine)
end

def meshing(base_dir,bin_dir)
	binName = bin_dir + "/aliceVision_meshing"
	srcIni = base_dir + "/05_PrepareDenseScene/mvs.ini"
	srcDepthFilterDir = base_dir + "/08_DepthMapFilter"
	srcDepthMapDir = base_dir + "/07_DepthMap"

	dstDir = base_dir + "/09_Meshing"

	cmdLine = binName
	cmdLine = cmdLine + " --simGaussianSizeInit 10.0 --maxInputPoints 50000000 --repartition multiResolution"
	cmdLine = cmdLine + " --simGaussianSize 10.0 --simFactor 15.0 --voteMarginFactor 4.0 --contributeMarginFactor 2.0 --minStep 2 --pixSizeMarginFinalCoef 4.0 --maxPoints 5000000 --maxPointsPerVoxel 1000000 --angleFactor 15.0 --partitioning singleBlock"
	cmdLine = cmdLine + " --minAngleThreshold 1.0 --pixSizeMarginInitCoef 2.0 --refineFuse True --verboseLevel info"

	cmdLine = cmdLine + " --ini \"" + srcIni + "\""
	cmdLine = cmdLine + " --depthMapFilterFolder \"" + srcDepthFilterDir + "\""
	cmdLine = cmdLine + " --depthMapFolder \"" + srcDepthMapDir + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "/mesh.obj\""
	
	command_line(cmdLine)
end

def mesh_filtering(base_dir,bin_dir)
	binName = bin_dir + "/aliceVision_meshFiltering"

	srcMesh = base_dir + "/09_Meshing/mesh.obj"
	dstMesh = base_dir + "/10_MeshFiltering/mesh.obj"

	cmdLine = binName
	cmdLine = cmdLine + " --verboseLevel info --removeLargeTrianglesFactor 60.0 --iterations 5 --keepLargestMeshOnly True"
	cmdLine = cmdLine + " --lambda 1.0"

	cmdLine = cmdLine + " --input \"" + srcMesh + "\""
	cmdLine = cmdLine + " --output \"" + dstMesh + "\""

	command_line(cmdLine)
end

def texturing(base_dir,bin_dir)
	binName = bin_dir + "/aliceVision_texturing"

	srcMesh = base_dir + "/10_MeshFiltering/mesh.obj"
	srcRecon = base_dir + "/09_Meshing/denseReconstruction.bin"
	srcIni = base_dir + "/05_PrepareDenseScene/mvs.ini"
	dstDir = base_dir + "/11_Texturing"

	cmdLine = binName
	cmdLine = cmdLine + " --textureSide 8192"
	cmdLine = cmdLine + " --downscale 2 --verboseLevel info --padding 15"
	cmdLine = cmdLine + " --unwrapMethod Basic --outputTextureFileType png --flipNormals False --fillHoles False"

	cmdLine = cmdLine + " --inputDenseReconstruction \"" + srcRecon + "\""
	cmdLine = cmdLine + " --inputMesh \"" + srcMesh + "\""
	cmdLine = cmdLine + " --ini \"" + srcIni + "\""
	cmdLine = cmdLine + " --output \"" + dstDir + "\""

	command_line(cmdLine)
end

def run_alice_vision(mesh_lab_dir,img_dir,bin_dir,num_of_imgs,run_step = nil)
	puts "Alice Vision Scan Prelim"
	puts "V 0.1"
	puts "Meshroom 2018"
	base_dir = ARGV[1] ? ARGV[1] : mesh_lab_dir
	src_image_dir = ARGV[2] ? ARGV[2] : img_dir
	bin_dir = ARGV[3] ? ARGV[3] : bin_dir
	num_images = ARGV[4] ? ARGV[4].to_i : num_of_imgs
	run_step = ARGV[5] ? ARGV[5] : "runall"

	puts "Base dir  : #{base_dir}"
	puts "Image dir : #{src_image_dir}"
	puts "Bin dir   : #{bin_dir}"
	puts "Num images: #{num_images}"
	puts "Step      : #{run_step}"

	if run_step == "runall"
		camera_init(base_dir,bin_dir,src_image_dir)
		feature_extraction(base_dir,bin_dir,num_images)
		image_matching(base_dir,bin_dir)
		feature_matching(base_dir,bin_dir)
		structure_from_motion(base_dir,bin_dir)
		prepare_dense_scene(base_dir,bin_dir)
		camera_connection(base_dir,bin_dir)
		depth_map(base_dir,bin_dir,num_images,3)
		depth_map_filter(base_dir,bin_dir)
		meshing(base_dir,bin_dir)
		mesh_filtering(base_dir,bin_dir)
		texturing(base_dir,bin_dir)
	elsif run_step == "run00"
		camera_init(base_dir,bin_dir,src_image_dir)
	elsif run_step == "run01"
		feature_extraction(base_dir,bin_dir,num_images)
	elsif run_step == "run02"
		image_matching(base_dir,bin_dir)
	elsif run_step == "run03"
		feature_matching(base_dir,bin_dir)
	elsif run_step == "run04"
		structure_from_motion(base_dir,bin_dir)
	elsif run_step == "run05"
		prepare_dense_scene(base_dir,bin_dir)
	elsif run_step == "run06"
		camera_connection(base_dir,bin_dir)
	elsif run_step == "run07"
		depth_map(base_dir,bin_dir,num_images,3)
	elsif run_step == "run08"
		depth_map_filter(base_dir,bin_dir)
	elsif run_step == "run09"
		meshing(base_dir,bin_dir)
	elsif run_step == "run10"
		mesh_filtering(base_dir,bin_dir)
	elsif run_step == "run11"
		texturing(base_dir,bin_dir)
	else
		puts "Invalid Step: #{run_step}"
	end
end

def manually_run_alice_vision(mesh_lab_dir,img_dir,bin_dir,num_of_imgs,run_step = nil)
	program_name = "run_alice.rb"
	mld = mesh_lab_dir
	idir = img_dir
	bd = bin_dir
	ni = num_of_imgs
	if run_step != nil
		selection = run_step
	else
		selection = "runall"
	end
	system( "ruby #{program_name} #{mld} #{idir} #{bd} #{ni} #{selection}" )
end
root = "G:/Downloads/run_alicevision"
base_dir = "#{root}/temp"
image_dir = "#{root}/dataset_monstree-master/full"
bin_dir = "G:/Downloads/Meshroom-2018.1.0-win64/Meshroom-2018.1.0/aliceVision/bin"
run_alice_vision(base_dir, image_dir, bin_dir, 6)