class Admin::BranchesController < Admin::BaseController
  before_action :set_branch, only: [:edit, :update]

  def index
    @areas = Area.includes(:branches).order(:id)
  end

  def edit
  end

  def update
    if @branch.update(branch_params)
      redirect_to admin_branches_path,
        notice: "#{@branch.name}の情報を更新しました。新しいデフォルト定員は、今後生成されるSlotから適用されます。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_branch
    @branch = Branch.find(params[:id])
  end

  def branch_params
    params.require(:branch).permit(:name, :address, :phone, :open_hours, :default_capacity)
  end
end
