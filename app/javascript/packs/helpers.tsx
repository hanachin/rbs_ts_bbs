import React, { useState } from 'react'

export const pluralize = (count, noun) => count === 0 ? noun : noun + 's'
export const i18n = key => key === 'title' ? 'Title' : ''
export const label = key => (
  <label htmlFor="title">{i18n('title')}</label>
)
export const textField = (key, initialValue: string) => {
  const [value, setValue] = useState<string>(initialValue)
  const handleChange = (e) => { setValue(e.target.value) }
  return <input type="text" name={key} id={key} value={value} onChange={handleChange} />
}
export const submit = ({ disabled, value }: { disabled: boolean, value: string }) => (
  <input type="submit" name="commit" value={value} disabled={disabled} />
)
