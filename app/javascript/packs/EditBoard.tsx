import React from 'react'
import ReactDOM from 'react-dom'
import { BoardForm } from './BoardForm'
import { boards, board } from './rbs_ts_routes'
import { railsApi } from './rbs_ts_runtime'

const EditBoard = ({ id, title }: { id: number, title: string }) => {
  const handleSubmit = ({ title: newTitle }: { title: string }) => {
    const result = railsApi('PATCH' as const, board, { id: id, title: newTitle})
    return result.then(({ json }) => {
      if (json instanceof Array) {
        return Promise.reject(json)
      } else {
        window.location.href = board.path({ id: json.id })
        return Promise.resolve()
      }
    })
  }
  return (
    <>
      <h1>Editing Board</h1>
      <BoardForm title={title} submit={'Update Board'} onSubmit={handleSubmit} />
      <a href={board.path({ id })}>Show</a>
      &nbsp;|&nbsp;
      <a href={boards.path({})}>Back</a>
    </>
  )
}

document.addEventListener('turbolinks:load', () => {
  const element = document.getElementById('edit-board')

  if (!element) return

  const props = JSON.parse(element.dataset.board)
  ReactDOM.render(
    <EditBoard {...props} />,
    element,
  )
})
