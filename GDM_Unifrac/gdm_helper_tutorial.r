# 0. Load up dependencies, make fake data so tutorial works
	library(gdm)
		set.seed(12345)
		pc <- runif(26, 0, 1)
		unif_dm <- as.matrix(dist(pc))
		rownames(unif_dm) <- colnames(unif_dm) <- letters
		metadata <- data.frame(
			Elevation = pc + runif(26, 0, 1) * 0.5,
			NDVI = pc + runif(26, 0, 1) * 0.7,
			Rainfall = pc - runif(26, 0, 1) * 0.4,
			latitude = 1:26,
			longitude = 1:26
		)
		rownames(metadata) <- letters

# 1. Let's say you have your UniFrac distance matrix in R, as a nxn numeric matrix
	# with row names and column names included (sample IDs). It's called 'unif_dm'.
	# Let's say you also have some metadata, as a data frame with n rows, and it 
	# includes row names, which are the same (same order!!!) as the row names of
	# your UniFrac distance matrix. it's called 'metadata'.

# 2. test some assumptions:
	# do our objects match up? All of these should return TRUE
	nrow(unif_dm) == ncol(unif_dm)
	nrow(unif_dm) == nrow(metadata)
	all(rownames(unif_dm) == colnames(unif_dm))
	all(rownames(unif_dm) == rownames(metadata))
	# gdm assumes 0-1 range of distances, but UniFrac doesn't always provide that.
	# usually max is like 1.2 or something, not a huge re-scale.
	# fix is to re-scale:
	unif_dm <- unif_dm/max(unif_dm)

# 3. make site-pair table
	# now we'll need the helper scripts.
	source("jld_gdm_helpers.r")
	# and we'll make a list of the predictors we want to use.
	# note that location data are a list, with labels Lat and Lon. Must have those
	# names if location is included (but it doesn't have to be).
	# NOTE - distance matrix inputs to GDM just go in this list.
	predictor_list <- list(
		Elevation=metadata$Elevation,
		NDVI=metadata$NDVI,
		Rainfall=metadata$Rainfall,
		Location=list(Lat=metadata$latitude, Lon=metadata$longitude) # MUST be named Lat and Lon!!
	)

# 4. make site-pair table from predictor_list
	spt <- site_pair_from_list( responseMat=unif_dm, predList=predictor_list )
	
# 5. run GDM
	# make geo=F if you didn't include location in predictor_list
	fit1 <- gdm(spt, geo=T)
	# you can also use gdm.varImp to do backward elimination, TAKES FOREVER
	# variables_importance <- gdm.varImp(spt, geo=T, fullModelOnly=FALSE, parallel=TRUE, cores=4)


# 6. plot GDM
	plot_gdm_jld(fit1, pred_colors="auto")

