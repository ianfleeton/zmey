class Admin::PostsController < Admin::AdminController
  before_action :set_post

  def edit
  end

  def update
    if @post.update_attributes(post_params)
      redirect_to @post.topic
    else
      render :edit
    end
  end

  private

    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.require(:post).permit(:author, :content, :email)
    end
end
