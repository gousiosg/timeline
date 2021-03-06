#' Creates a timeline plot.
#' 
#' This function will create a timeline using the \code{ggplot2} framework in a
#' style similar to \href{http://www.preceden.com/}{Preceden}. There are two
#' types of events, those that have a range (i.e. a start and end date) and
#' and points-in-time. The latter can be grouped in separate rows to prevent
#' overlapping or to organize different types of events. Grouping of point-in-time
#' events will color code those events accordingly.
#' 
#' @param df data for time periods.
#' @param events data for events (optional).
#' @param label.col the column name in \code{df} to use for labeling.
#' @param group.col the column name in \code{df} to use for grouping.
#' @param start.col the column name in \code{df} that specifies the start date.
#' @param end.col the column name in \code{df} that specifies the end date.
#' @param display.label whether the labels should be displayed.
#' @param text.size the text size for labels in \code{df}.
#' @param text.color the text color for labels in \code{df}.
#' @param text.position the positioning of the text (i.e. left, right, or center).
#' @param text.alpha the alpha level for labels.
#' @param text.angle the angle for labels.
#' @param text.family the font family for labels.
#' @param text.fontface the font face for labels.
#' @param text.hjust the horizontal adjustement for labels. The default will be
#'        set based upon the value of \code{text.position}.
#' @param text.vjust the vertical adjustement for labels.
#' @param text.lineheight the lineheight for labels.
#' @param num.label.steps the number of steps to use for labeling events.
#' @param event.label.col the column name in \code{events} to use for labeling.
#' @param event.col the column name in \code{events} that specifies the date.
#' @param event.group.col the column name in \code{events} to use for grouping.
#' @param event.spots the number of rows to use for events. Note that each group
#'        in \code{df} is equal to one, so \code{event.spots = 2} would be
#'        twice as high as one group row from \code{df}.
#' @param event.label the label to use on the x-axis for events.
#' @param event.label.method the labeling method. For \code{method = 1} labels
#'        are printed horizontally; for \code{method = 2} labels are printed at
#'        45 degree angles.
#' @param event.line whether to draw a vertical line for each event.
#' @param event.text.color the text color of event labels.
#' @param event.text.size the text size for event event labels.
#' @param event.text.alpha the alpha level for event labels.
#' @param event.text.angle the angle for event labels.
#' @param event.text.family the font family for event labels.
#' @param event.text.fontface the font face for event labels.
#' @param event.text.vjust the vertical adjustement for event labels.
#' @param event.text.lineheight the lineheight for event labels.
#' @param event.above whether events should be plotted above (\code{TRUE}) or
#'        below (\code{FALSE}) time bars.
#' @param border.color the color of the border around each box.
#' @param border.linetype the linetype of the border around each box.
#' @param limits the limits of the y-axis.
#' @param ... currently unused.
#' @export
#' @examples
#' data(ww2)
#' timeline(ww2, ww2.events)
#' timeline(ww2, ww2.events, event.spots=2, event.label='', event.above=FALSE)
timeline <- function(df, events,
					 label.col = names(df)[1],
					 group.col = names(df)[2],
					 start.col = names(df)[3],
					 end.col = names(df)[4],
					 display.label = T,
           text.position = c('left','right','center'),
					 text.size = 4,
					 text.color = 'black',
					 text.alpha = 1, 
					 text.angle = 0, 
					 text.family = 'serif', 
					 text.fontface = 1,
					 text.hjust,
					 text.vjust = 0.5, 
					 text.lineheight = 1, 
					 num.label.steps = 5,
					 event.label.col,
					 event.col,
					 event.group.col,
					 event.spots = 1,
					 event.label = '',
					 event.label.method = 1,
					 event.line = FALSE,
					 event.text.size = 4,
					 event.text.color = 'black',
					 event.text.alpha = 1, 
					 event.text.angle = 0, 
					 event.text.family = 'serif', 
					 event.text.fontface = 1,
					 event.text.vjust = 0.5, 
					 event.text.lineheight = 1, 
					 event.above = TRUE,
					 border.color='white',
					 border.linetype=1,
					 limits,
					 ...
) {	
	p <- ggplot()

	if(!missing(events)) {
		if(missing(event.label.col)) {
			event.label.col <- names(events)[1]
		}
		if(missing(event.col)) {
			event.col <- names(events)[2]
		}
		if(missing(event.group.col)) {
			event.group.col <- NULL
		}
	} else {
		event.spots <- 0
	}
	
	if(missing(limits)) {
		if(missing(events)) {
			limits <- range(c(df[,start.col], df[,end.col]), na.rm=TRUE)
		} else if(missing(df)) {
			limits <- range(events[,event.col], na.rm=TRUE)
		} else {
			limits <- range(c(df[,start.col], df[,end.col], events[,event.col]), na.rm=TRUE)
		}
	}
	
	groups <- unique(df[,group.col])
	xmin <- limits[1]
	xmax <- limits[2]
	
	ymin <- 0
	ymax <- length(groups)
	
	group.labels <- data.frame(group=groups, 
							   x=rep(xmin, length(groups)), 
							   y=rep(NA, length(groups)),
							   stringsAsFactors=FALSE)
	
	df$ymin <- df$ymax <- NA
	for(i in seq_along(groups)) {
		df[which(df[,group.col] == groups[i]),]$ymin <- 
			ifelse(event.above, 0, event.spots - 1) + i - event.above
		df[which(df[,group.col] == groups[i]),]$ymax <- 
			ifelse(event.above, 0, event.spots - 1) + i + !event.above
		group.labels[which(group.labels$group == groups[i]),]$y <- 
			ifelse(event.above, 0, event.spots - 1) + i + !event.above
	}
	df$labelpos <- (df$ymin + df$ymax) / 2
	
	if(text.position[1] == 'right') {
		if(missing(text.hjust)) {
			text.hjust <- 1.05
		}
		df$labelpos.x <- df[,end.col]
	} else if(text.position[1] == 'center') {
		if(missing(text.hjust)) {
			text.hjust <- .5
		}
		df$labelpos.x <- df[,start.col] + as.integer(df[,end.col] - df[,start.col]) / 2
	} else {
		if(missing(text.hjust)) {
			text.hjust <- -0.05
		}
		df$labelpos.x <- df[,start.col]
	}
	
	if(!missing(events)) {
		if(num.label.steps > 1) {
			steps <- rev(seq(0, event.spots, by=event.spots/
							 	(num.label.steps + 1))[2:(num.label.steps+1)])
			events$y <- ifelse(event.above, ymax, 0) + 
				rep(steps, ceiling(nrow(events)/length(steps)))[1:nrow(events)]
		} else {
			events$y <- ifelse(event.above, ymax, 0)
		}
	}
	
	group.labels <- rbind(group.labels, data.frame(group=event.label, x=xmin, 
							y=ifelse(event.above, ymax + 1, 1)))
	
	#Fix the dates that fall outside the range
	df[df[,start.col] < xmin & df[,end.col] > xmin, start.col] <- xmin
	df[df[,end.col] > xmax & df[,start.col] < xmax, end.col] <- xmax
	if(!missing(events)) {
		events <- events[events[,event.col] >= xmin & events[,event.col] <= xmax,]
		if(event.line) {
			p <- p + geom_segment(data=events, 
				aes_string(x=event.col, xend=event.col, yend='y'), 
				y=ifelse(event.above, ymin, event.spots), alpha=1)
		}
		
	}
	
	p <- p +
		geom_rect(data=df, aes_string(xmin=start.col, xmax=end.col,
		          ymin='ymin', ymax='ymax', fill=label.col), alpha=.9, 
				  color=border.color, linetype=border.linetype) 
    if (display.label) {
    	p <- p +
        geom_text(data=df, aes_string(y='labelpos', x='labelpos.x',
                                      label=label.col),
                  hjust=text.hjust,
		    		      size=text.size,
				          color=text.color,
				          alpha=text.alpha,
				          angle=text.angle,
				          family=text.family,
    				      fontface=text.fontface,
		    		      vjust=text.vjust,
				          lineheight=text.lineheight)
    }
	p <- p + theme(legend.position='none',
                 axis.ticks.y=element_blank()) + 
		xlab('') + ylab('') +
		xlim(c(xmin, xmax)) +
		scale_y_continuous(breaks=group.labels$y-0.5, 
						   labels=group.labels$group,
						   limits=c(ymin, ymax + event.spots),
						   minor_breaks=c())
	if(!missing(events)) {
		if(missing(event.group.col)) {
			events$Group <- 'Group'
			event.group.col <- 'Group'
		}
		if(event.label.method == 1) {
			p <- p +
				geom_point(data=events, aes_string(x=event.col, y='y',
				     color=event.group.col)) +
				geom_text(data=events, aes_string(x=event.col, y='y', 
				     label=event.label.col, color=event.group.col), hjust=-0.05,
				     size=event.text.size,
					 color=event.text.color,
					 alpha=event.text.alpha, 
					 angle=event.text.angle, 
					 family=event.text.family, 
					 fontface=event.text.fontface,
					 vjust=event.text.vjust, 
					 lineheight=event.text.lineheight)
		} else if(event.label.method == 2) {
			p <- p +
				geom_point(data=events, aes_string(x=event.col, y='y', color=event.group.col)) +
				geom_text(data=events, aes_string(x=event.col, y='y', label=event.label.col,
				     color=event.group.col), angle=45, 
					 vjust=ifelse(event.above, -0.15, 0),
					 hjust=ifelse(event.above, -0.15, 0),
				     size=event.text.size,
					 color=event.text.color,
					 alpha=event.text.alpha, 
					 angle=event.text.angle, 
					 family=event.text.family, 
					 fontface=event.text.fontface,
					 vjust=event.text.vjust, 
					 lineheight=event.text.lineheight)
		} else if(event.label.method == 3) {
			p <- p +
				geom_point(data=events, aes_string(x=event.col, y='y', color=event.group.col)) +
				geom_text(data=events, aes_string(x=event.col, label=event.label.col,
					 color=event.group.col, y='y'), angle=90, 
					 hjust=ifelse(event.above, -0.15, 0.15), 
					 vjust=ifelse(event.above, 0, 0),
					 size=event.text.size,
					 color=event.text.color,
					 alpha=event.text.alpha, 
					 angle=event.text.angle, 
					 family=event.text.family, 
					 fontface=event.text.fontface,
					 vjust=event.text.vjust, 
					 lineheight=event.text.lineheight)
		}
		if(length(unique(events[,event.group.col])) == 1) {
			p <- p + scale_color_grey()
		}
	}
	
	p <- p + geom_hline(yintercept=ifelse(event.above, 0, event.spots), size=1)
	
	return(p)
}
