#' Evaluate if data are appropriate for PCA / Factor analysis
#'
#' @details See \url{https://radiant-rstats.github.io/docs/multivariate/pre_factor.html} for an example in Radiant
#'
#' @param dataset Dataset name (string). This can be a dataframe in the global environment or an element in an r_data list from Radiant
#' @param vars Variables to include in the analysis
#' @param data_filter Expression entered in, e.g., Data > View to filter the dataset in Radiant. The expression should be a string (e.g., "price > 10000")
#'
#' @return A list with all variables defined in the function as an object of class pre_factor
#'
#' @examples
#' result <- pre_factor("diamonds",c("price","carat","table"))
#'
#' @seealso \code{\link{summary.pre_factor}} to summarize results
#' @seealso \code{\link{plot.pre_factor}} to plot results
#'
#' @importFrom psych KMO cortest.bartlett
#'
#' @export
pre_factor <- function(dataset, vars,
                       data_filter = "") {

	dat <- getdata(dataset, vars, filt = data_filter)
	nrObs <- nrow(dat)

	if (!is_string(dataset)) dataset <- deparse(substitute(dataset)) %>% set_attr("df", TRUE)

	if (nrObs <= ncol(dat)) {
		return("Data should have more observations than variables.\nPlease reduce the number of variables." %>%
		       add_class("pre_factor"))
	}

  cmat <- cor(dat)
	btest <- psych::cortest.bartlett(cmat, nrow(dat))
	pre_kmo <- psych::KMO(cmat)
	pre_eigen <- eigen(cmat)$values

  err_mess <- "The selected variables are perfectly collinear. Please check the correlations\nand remove any variable with a correlation of 1 or -1 from the analysis"
  if (det(cmat) > 0) {
    scmat <- try(solve(cmat), silent = TRUE)
    if (is(scmat, 'try-error')) {
    	pre_r2 <- err_mess
    } else {
    	pre_r2 <- {1 - (1 / diag(scmat))} %>%
    							data.frame %>%
    							set_colnames('Rsq')
    }
  } else {
  	pre_r2 <- err_mess
  }

  rm(dat)

  as.list(environment()) %>% add_class("pre_factor")
}

#' Summary method for the pre_factor function
#'
#' @details See \url{https://radiant-rstats.github.io/docs/multivariate/pre_factor.html} for an example in Radiant
#'
#' @param object Return value from \code{\link{pre_factor}}
#' @param dec Rounding to use for output
#' @param ... further arguments passed to or from other methods
#'
#' @examples
#' result <- pre_factor("diamonds",c("price","carat","table"))
#' summary(result)
#' diamonds %>% pre_factor(c("price","carat","table")) %>% summary
#' result <- pre_factor("computer","high_end:business")
#' summary(result)
#'
#' @seealso \code{\link{pre_factor}} to calculate results
#' @seealso \code{\link{plot.pre_factor}} to plot results
#'
#' @export
summary.pre_factor <- function(object, dec = 2, ...) {

	if (is.character(object)) return(cat(object))

	if (is.character(object$pre_r2)) {
		cat(object$pre_r2)
		return(invisible())
	}

	cat("Pre-factor analysis diagnostics\n")
	cat("Data        :", object$dataset, "\n")
	if (object$data_filter %>% gsub("\\s","",.) != "")
		cat("Filter      :", gsub("\\n","", object$data_filter), "\n")
	cat("Variables   :", paste0(object$vars, collapse=", "), "\n")
	cat("Observations:", object$nrObs, "\n")

	btest <- object$btest
	cat("\nBartlett test\n")
	cat("Null hyp.: variables are not correlated\n")
	cat("Alt. hyp.: variables are correlated\n")
	bt <- object$btest$p.value %>% { if (. < .001) "< .001" else round(.,dec + 1) }
	cat(paste0("Chi-square: ", round(object$btest$chisq,2), " df(",
	    object$btest$df, "), p.value ", bt, "\n"))

	cat("\nKMO test: ", round(object$pre_kmo$MSA, dec), "\n")
	# cat("\nMeasures of sampling adequacy:\n")
	# print(object$pre_kmo$MSAi, digits = dec)

  cat("\nVariable collinearity:\n")
  print(round(object$pre_r2, dec), digits = dec)

	cat("\n")
	object$pre_eigen %>%
	  { data.frame(Factor = 1:length(.),
							   Eigenvalues = round(., dec),
							   `Variance %` = ./sum(.),
							   `Cumulative %` = cumsum(./sum(.)),
							   check.names = FALSE) } %>%
	  round(dec) %>%
	  print(., row.names = FALSE)
}

#' Plot method for the pre_factor function
#'
#' @details See \url{https://radiant-rstats.github.io/docs/multivariate/pre_factor.html} for an example in Radiant
#' @param x Return value from \code{\link{pre_factor}}
#' @param plots Plots to return. "change" shows the change in eigenvalues as variables are grouped into different number of factors, "scree" shows a scree plot of eigenvalues
#' @param cutoff For large datasets plots can take time to render and become hard to interpret. By selection a cutoff point (e.g., eigenvalues of .8 or higher) factors with the least explanatory power are removed from the plot
#' @param shiny Did the function call originate inside a shiny app
#' @param custom Logical (TRUE, FALSE) to indicate if ggplot object (or list of ggplot objects) should be returned. This opion can be used to customize plots (e.g., add a title, change x and y labels, etc.). See examples and \url{http://docs.ggplot2.org/} for options.
#' @param ... further arguments passed to or from other methods
#'
#' @examples
#' result <- pre_factor("diamonds",c("price","carat","table"))
#' plot(result)
#' plot(result, plots = c("change", "scree"), cutoff = .05)
#'
#' @seealso \code{\link{pre_factor}} to calculate results
#' @seealso \code{\link{summary.pre_factor}} to summarize results
#'
#' @export
plot.pre_factor <- function(x, plots = c("scree","change"),
                           	cutoff = 0.2,
                           	shiny = FALSE,
                           	custom = FALSE,
                            ...) {

	object <- x; rm(x)
	if (is.character(object) || is.character(object$pre_r2) ||
	    length(plots) == 0) return(invisible())

	cutoff <- ifelse(is_not(cutoff), .2, cutoff)

	pre_eigen <- with(object, pre_eigen[pre_eigen > cutoff])
	dat <- data.frame(y = pre_eigen, x = 1:length(pre_eigen))

	plot_list <- list()
	if ("scree" %in% plots) {
		plot_list[[which("scree" == plots)]] <- ggplot(dat, aes(x=x, y=y, group = 1)) +
		    geom_line(colour="blue", linetype = 'dotdash', size=.7) +
		    geom_point(colour="blue", size=4, shape=21, fill="white") +
				geom_hline(yintercept = 1, color = 'black', linetype = 'solid', size = 1) +
			  labs(list(title = "Screeplot", x = "# factors", y = "Eigenvalues"))
	}

	if ("change" %in% plots) {
		plot_list[[which("change" == plots)]] <- pre_eigen %>%
			{(. - lag(.)) / lag(.)} %>%
			{. / min(., na.rm = TRUE)} %>%
				data.frame(bump = ., nr_fact = paste0(0:(length(.)-1), "-", 1:length(.))) %>%
				na.omit() %>%
				ggplot(aes(x=factor(nr_fact, levels = nr_fact), y=bump)) +
					geom_bar(stat = "identity", alpha = .5) +
					labs(list(title = paste("Change in Eigenvalues"),
					     x = "# factors", y = "Rate of change index"))
	}

  if (custom)
    if (length(plot_list) == 1) return(plot_list[[1]]) else return(plot_list)

	sshhr(gridExtra::grid.arrange(grobs = plot_list, ncol = 1)) %>%
	 	{if (shiny) . else print(.)}
}
