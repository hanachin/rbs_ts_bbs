import React from 'react'
import ReactDOM from 'react-dom'
import { railsApi } from "./runtime"
import { board, boards } from "./routes"

type Board = { id: number; title: string }
const ListBoards = ({ boards, notice }: { boards: Board[], notice: string }) => {
  return (
    <>
      <p id="notice">{notice}</p>

      <h1>Boards</h1>

      <table>
        <thead>
          <tr>
            <th>Title</th>
            <th colSpan={3}></th>
          </tr>
        </thead>

        <tbody>
          {boards.map(b => {
            const handleDestroy = (e) => {
              if (confirm('Are you sure?')) {
                railsApi('DELETE' as const, board, b).then(() => {
                  window.location.href = '/boards'
                })
              }
              e.preventDefault()
            }
            return (
              <tr key={b.id}>
                <td>{b.title}</td>
                <td><a href={`/boards/${b.id}`}>Show</a></td>
                <td><a href={`/boards/${b.id}/edit`}>Edit</a></td>
                <td><a href={`/boards/${b.id}`} onClick={handleDestroy}>Destroy</a></td>
              </tr>
            )
          })}
        </tbody>
      </table>

      <br/>

      <a href={`/boards/new`}>New Board</a>
    </>
  )
}

document.addEventListener('turbolinks:load', () => {
  const element = document.getElementById('boards')

  if (!element) return

  const result = railsApi('GET' as const, boards, {})
  result.then(({ json }) => {
    ReactDOM.render(
      <ListBoards notice={''} boards={json} />,
      element,
    )
  })})
