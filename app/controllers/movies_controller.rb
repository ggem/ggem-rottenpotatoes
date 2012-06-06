class MoviesController < ApplicationController
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if update_session
      flash.keep
      redirect_to movies_path(params)
      return
    end
    @movies = Movie.scoped
    @movies = @movies.where(:rating => params[:ratings].keys)
    if params[:sort_by] == 'title'
      @movies = @movies.order('title ASC')
      @title_class = :hilite
    elsif params[:sort_by] == 'release'
      @movies = @movies.order('release_date ASC')
      @release_date_class = :hilite
    end
    @all_ratings = Movie.all_ratings
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

  private

  def sanitize_params
    params.keep_if{|k,v| ["sort_by", "ratings"].include?(k) }
  end
  
  def update_session
    needs_redirect = false
    if params[:ratings].nil?
      needs_redirect = true
      if (session_ratings=session[:ratings]).nil?
        params[:ratings] = Hash[Movie.all_ratings.map{|r| [r, "1"]}]
      else
        params[:ratings] = session_ratings
      end
    else
      session[:ratings] = params[:ratings]
    end

    if params[:sort_by].nil?
      needs_redirect = true
      if (session_sort_by=session[:sort_by]).nil?
        params[:sort_by] = 'title'
      else
        params[:sort_by] = session_sort_by
      end
    else
      session[:sort_by] = params[:sort_by]
    end
    
    params.keep_if{|k, v| ["ratings", "sort_by"].include?(k) }
    needs_redirect
  end
end
