defmodule LangChain.LogProbs do
  @moduledoc """
  Contains log probability information returned from an LLM.

  ## Example

      %LogProbs{
        content: [
          %TokenLogProb{
            token: "Hello",
            logprob: -0.019925889,
            bytes: [72, 101, 108, 108, 111],
            top_logprobs: [
              %TopLogProb{token: "Hello", logprob: -0.019925889, bytes: [72, 101, 108, 108, 111]},
              %TopLogProb{token: "Hi", logprob: -4.644926, bytes: [72, 105]}
            ]
          }
        ],
        refusal: nil
      }

  The logprob values indicate the likelihood of each token occurring in the sequence.
  A logprob of 0.0 corresponds to 100% probability, while more negative values indicate lower probabilities.
  """
  use Ecto.Schema
  import Ecto.Changeset
  require Logger
  alias __MODULE__
  alias LangChain.LangChainError

  @primary_key false
  embedded_schema do
    embeds_many :content, __MODULE__.TokenLogProb
    field :refusal, :string
  end

  @type t :: %LogProbs{}

  defmodule TokenLogProb do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :token, :string
      field :logprob, :float
      field :bytes, {:array, :integer}
      embeds_many :top_logprobs, LangChain.LogProbs.TopLogProb
    end

    @type t :: %TokenLogProb{}

    def changeset(token_logprob, attrs) do
      token_logprob
      |> cast(attrs, [:token, :logprob, :bytes])
      |> cast_embed(:top_logprobs)
      |> validate_required([:token, :logprob])
    end
  end

  defmodule TopLogProb do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key false
    embedded_schema do
      field :token, :string
      field :logprob, :float
      field :bytes, {:array, :integer}
    end

    @type t :: %TopLogProb{}

    def changeset(top_logprob, attrs) do
      top_logprob
      |> cast(attrs, [:token, :logprob, :bytes])
      |> validate_required([:token, :logprob])
    end
  end

  @doc """
  Build a new LogProbs and return an `:ok`/`:error` tuple with the result.
  """
  @spec new(attrs :: map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def new(attrs \\ %{}) do
    %LogProbs{}
    |> cast(attrs, [:refusal])
    |> cast_embed(:content)
    |> apply_action(:insert)
  end

  @doc """
  Build a new LogProbs and return it or raise an error if invalid.
  """
  @spec new!(attrs :: map()) :: t() | no_return()
  def new!(attrs \\ %{}) do
    case new(attrs) do
      {:ok, logprobs} ->
        logprobs

      {:error, changeset} ->
        raise LangChainError, changeset
    end
  end

end
